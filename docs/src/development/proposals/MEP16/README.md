# metal-api as an Alternative Configuration Source for the firewall-controller

In the current situation, a firewall as provisioned by metal-stack is a fully immutable entity. Any modifications on the firewall like changing the firewall ruleset must be done _somehow_ by the user – the metal-api and hence the metal-stack is not aware of its current state. 

As part of our [integration with the Gardener project](https://docs.metal-stack.io/stable/overview/kubernetes/#Gardener) we offer a solution called the [firewall-controller](https://github.com/metal-stack/firewall-controller), which is part of our [firewall OS images](https://github.com/metal-stack/metal-images/blob/6318a624861b18a559a9d37299bca5f760eef524/firewall/Dockerfile#L57-L58) and addresses shortcomings of the firewall resource's immutability, which would otherwise be completely impractible to work with. The firewall-controller crashes infinitely if it is not properly configured through the userdata when using the firewall image of metal-stack.

The firewall-controller approach is tightly coupled to the Gardener and it requires the administrator of the Gardener installation to pass a shoot and a seed kubeconfig through machine userdata when creating the firewall. How this userdata has to look like is not documented and is just part of another project called the [firewall-controller-manager](https://github.com/metal-stack/firewall-controller-manager), which task is to orchestrate rolling updates of firewall machines in a way that network traffic interruption is minimal when updating a firewall or applying a change to an immutable firewall configuration.

In general, a firewall entity in metal-stack has similarities to the machine entity but it has a fundamental difference: A user gains ownership over a machine after provisioning. They can access it through SSH, modify it at will and this is completely wanted. For firewalls, however, we do not want a user to access the provisioned firewall as the firewall is a privileged part of the infrastructure with access to the underlay network. The underlay can not be tampered with at any given point in time by a user as it can destroy the entire network traffic flow inside a metal-stack partition.

For this reason, we have a gap in the metal-stack project in terms of a missing solution for people who do not rely on the Gardener integration. We are basically leaving a user with the option to implement an orchestrated recreation of every possible change on the firewall to minimize traffic interruption for the machines sitting behind the firewall or re-implement the firewall-controller to how they want to use it for their use-case. Also we do not have a clear distinction in the API between user and landscape operator for firewalls. If a user would allocate firewall it is also possible for the user to inject his own SSH keys and access the firewall and tamper with the underlay network. 

Parts of these problems are probably going to decrease with the work on [MEP-4](../MEP4/README.md) where there will be dedicated APIs for users and administrators of metal-stack including fine-grained access tokens.

With this MEP we want to describe a way to improve this current situation and allow other users that do not rely on the Gardener integration – for whatever motivation they have not to – to adequately manage firewalls. For this, we propose an alternative configuration for the firewall-controller that is native to metal-stack and more independent of the Gardener.

## Proposal

- The firewall-controller can use the metal-api as a configuration source.
- The firewall rules of the firewall entity can be updated through the metal-api.
- The firewall-controller can be configured through a dedicated config file.
- Inside this config file the data source for all its dynamic configuration tasks can be set independently.
- For example the data source of the core firewall rules could be set the Gardener seed or the metal-api firewall entity, while the CWNPs should be fetched and applied from a given kubeconfig (the shoot Kubeconfig in the Gardener case).
- This configuration file is intended to be injected through userdata along with potential source connection credentials.

```yaml
# the main configuration source contributes
# - firewall nftables rules
# - egress rules
# - prefixes
# - rate limiting
# - versions of components (firewall-controller, droptailer, ...)
main:
  kind: kubernetes
  config:
    kubeconfigPath: /etc/firewall-controller/seed.yaml
    components:
    - kind: Firewall
      namespace: shoot-namespace

# the additional configuration sources contributes
# - additional firewall nftables rules
additional:
- kind: kubernetes
  config:
    kubeconfigPath: /etc/firewall-controller/shoot.yaml
    components:
    - kind: ClusterwideNetworkPolicy
      namespace: firewall
    - kind: Service
      namespace: null

- kind: metal-api
  config:
    url: https://metal-api
    hmac: some-hmac
    type: Metal-View

- kind: static
  config:
    egress: []
    ingress: []

# the reports configuration output generates
# - FirewallMonitor
reports:
- kind: kubernetes
  config:
    kubeconfigPath: /etc/firewall-controller/shoot.yaml
    components:
    - kind: FirewallMonitor
      namespace: firewall
      name: firewall-monitor # default name of firewall
```

### Non-Goals

- Resolving the missing differentiation between users and administrators by lettings users pass userdata and SSH keys to the firewall creation.
  - This is even more related to MEP-4 than this MEP.

### Advantages

- Offers a native metal-stack solution that improves managing firewalls for users by adding dynamic reconfiguration through the metal-api
  - e.g., in the mini-lab, users can now allocate a machine, then an IP address and announce this IP from the machine without having to re-create the firewall but by adding a firewall rule to the firewall entity.
- Improve consistency throughout the API (firewall rules would reflect what is persisted in metal-api).
- Other providers like Cluster API can leverage this approach, too.
- It can contribute to solving the shoot migration issue (in Cluster API case the `clusterctl move` for firewall objects)
  - For Gardener takes the seed out of the equation (of which the kubeconfig changes during shoot migration)
  - However: Things like egress rules, rate limiting, etc. are currently not part of the firewall entity in the metal-api (these would need to be added to the firewall entity as otherwise there is no feature parity)

### Caveats

- Metal-View access is too broad for firewalls. Mitigated by MEP-4.
- Polling of the firewall-controller is bad for performance. Mitigated by MEP-4.

### Firewall Controller Manager

- firewall-controller
  - Allow OPTIONAL configuration source (metal-api with view HMAC), which is considered when no seed kubeconfig was passed in the userdata
- firewall-controller-manager
  - Update the firewall entity in the metal-api
- metal-api
  - Allow update of firewall rules in the machine allocation spec
  - Add egress rules, rate limiting, etc to the firewall entity

```yaml
kind: FirewallDeployment
spec:
    userdataContents:
    - path: /etc/firewall-controller/config.yaml
      content: |
        ---
        main:
        additional:
        reports:
    - path: /etc/firewall-controller/seed.yaml
      secretRef:
          name: seed-kubeconfig
    - path: /etc/firewall-controller/shoot.yaml
      secretRef:
          name: shoot-kubeconfig
    - path: /etc/firewall-controller/shoot.yaml
      generateGardenerFirewallControllerSecret: true
```

### Cluster API Provider Metal Stack

![architectural overview](firewall-for-capms-overview.svg)

In Cluster API there are essentially two main clusters: the management cluster and the workload cluster.
Typically a local bootstrap cluster is created in kind which acts as the management cluster. It creates the workload cluster. Thereafter the ownership of the workload cluster is typically moved to a different cluster which will then become the management cluster.
The new management cluster might actually be the workload cluster itself.

In contrast to Gardener, Cluster API tries to be as non-opinionated and as standard as possible. It is common practice to not install any non-required components or CRDs into the workload cluster. Therefore we cannot expect custom resources like `ClusterwideNetworkPolicy` or `FirewallMonitor` to be installed in the workload cluster. Therefore it's the responsibility of the operator to tell cluster-api-provider-metal-stack the kubeconfig for the cluster where these CRDs are installed and defined in.

A viable configuration for a `MetalStackCluster` that generates firewall rules based of `Service` type `LoadBalancer` and `ClusterwideNetworkPolicy` and expects them to be deployed in the workload cluster is shown below. The `FirewallMonitor` will be reported into the same cluster.

```yaml
kind: MetalStackCluster
metadata:
    name: ${CLUSTER_NAME}
spec:
    firewallTemplate:
        # existing fields omitted
        staticRuleSet: []
        additionalFiles:
        - path: /etc/firewall-controller/workload.yaml
          secretRef:
              # this is the kubeconfig generated by kubeadm
              name: ${CLUSTER_NAME}-kubeconfig
        
        controllerConfigSecretRef:
            secretName: ${CLUSTER_NAME}-firewall-controller-config
---
kind: Secret
metadata:
    name: ${CLUSTER_NAME}-firewall-controller-config
stringData:
    controllerConfig: |
        ---
        main:
            config:
                url: ${METAL_API_URL}
                hmac: ${METAL_API_HMAC}
                type: ${METAL_API_HMAC_TYPE}
        additional:
        - kind: kubernetes
          config:
              kubeconfigPath: /etc/firewall-controller/workload.yaml
              components:
              - kind: ClusterwideNetworkPolicy
                namespace: firewall
              - kind: Service
            
        reports:
        - kind: kubernetes
          config:
              kubeconfigPath: /etc/firewall-controller/workload.yaml
                  components:
                  - kind: FirewallMonitor
                    namespace: firewall
                    name: firewall-monitor-${CLUSTER_NAME}
```

This approach allows maximum flexibility as intended by Cluster API and is still able to provide robust rolling updates of firewalls.

An advanced use case of this flexibility would be a management cluster, that is in charge of multiple workload clusters. Where one workload cluster acts as a monitoring or tooling cluster, receives logs and the firewall monitor for the other workload clusters. The CWNPs could be defined here, all in a separate namespace.

## Roadmap

In general this proposal is not thought to be implemented in one batch. Instead an incremental approach is required.

1. Allow Cluster API to use the FCM (provide immutable firewalls that run without firewall-controller).
   - Add `spec.staticRuleSet` to Firewall.
   - Add `firewall.metal-stack.io/paused` annotation (managed by CAPMS during move, theoretically useful for Gardener shoot migration as well to avoid shallow deletion).
   - Reconcile multiple `FirewallDeployment` resources per namespace.
   - Allow setting the `firewall.metal-stack.io/no-controller-connection` annotation through the `FirewallDeployment` (either through the template or inheritance)
2. Extend firewall-controller with the configuration file (no different data sources than kubernetes) and let the FCM generate this configuration file along with the rest of the userdata.
3. Add metal-api as configuration source.
   - Allow updates of firewall rules in the firewall entity.
   - For Cluster API: Let the cluster controller generate the userdata including the configuration for this additional data source.
4. Move to more generic interface for the FCM (remove Gardener coupling)


## Alternatives Considered

- instead of the generic data sources, for each mechanism a kubeconfig could be provided. Though this is not a scalable nor flexible approach. In the end the same internal data structure is still needed.
