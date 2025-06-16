# metal-api as an Alternative Configuration Source for the firewall-controller

In the current situation, a firewall as provisioned by metal-stack is a fully immutable entity. Any modifications on the firewall like changing the firewall ruleset must be done _somehow_ by the user – the metal-api and hence metal-stack is not aware of its current state.

As part of our [integration with the Gardener project](https://docs.metal-stack.io/stable/overview/kubernetes/#Gardener) we offer a solution called the [firewall-controller](https://github.com/metal-stack/firewall-controller), which is part of our [firewall OS images](https://github.com/metal-stack/metal-images/blob/6318a624861b18a559a9d37299bca5f760eef524/firewall/Dockerfile#L57-L58) and addresses shortcomings of the firewall resource's immutability, which would otherwise be completely impractible to work with. The firewall-controller crashes infinitely if it is not properly configured through the userdata when using the firewall image of metal-stack.

The firewall-controller approach is tightly coupled to Gardener and it requires the administrator of the Gardener installation to pass a shoot and a seed kubeconfig through machine userdata when creating the firewall. How this userdata has to look like is not documented and is just part of another project called the [firewall-controller-manager](https://github.com/metal-stack/firewall-controller-manager) (FCM), which task is to orchestrate rolling updates of firewall machines in a way that network traffic interruption is minimal when updating a firewall or applying a change to an immutable firewall configuration.

In general, a firewall entity in metal-stack has similarities to the machine entity but it has a fundamental difference: A user gains ownership over a machine after provisioning. They can access it through SSH, modify it at will and this is completely wanted. For firewalls, however, we do not want a user to access the provisioned firewall as the firewall is a privileged part of the infrastructure with access to the underlay network. The underlay can not be tampered with at any given point in time by a user as it can destroy the entire network traffic flow inside a metal-stack partition.

For this reason, we have a gap in the metal-stack project in terms of a missing solution for people who do not rely on the Gardener integration. We are basically leaving a user with the option to implement an orchestrated recreation of every possible change on the firewall to minimize traffic interruption for the machines sitting behind the firewall or re-implement the firewall-controller to how they want to use it for their use-case.

Also we do not have a clear distinction in the API between user and metal-stack operator for firewalls. If a user would allocate a firewall it is also possible for the user to inject his own SSH keys and access the firewall and tamper with the underlay network.

Parts of these problems are probably going to decrease with the work on [MEP-4](../MEP4/README.md) where there will be dedicated APIs for users and administrators of metal-stack including fine-grained access tokens.

With this MEP we want to describe a way to improve this current situation and allow other users that do not rely on the Gardener integration – for whatever motivation they have – to adequately manage firewalls. For this, we propose an alternative configuration for the firewall-controller that is native to metal-stack and more independent of Gardener.

## Proposal

The central idea of this proposal is allowing the firewall-controller to use the metal-api as a configuration source. This should serve as an alternative strategy to the currently used FCM `Firewall` resource based approach in the Gardener use-case.
Updates of the firewall rules should be possible through the metal-api.

The firewall-controller itself should now be able to decide which of the two main strategies should be used for the base configuration: a kubeconfig or the metal-api. This should be possible through a dedicated _firewall-controller-config_.

Using this config will now allow operators to fine-tune the data sources for all of its dynamic configuration tasks independently.
For example the data source of the core firewall rules could be set either from the `Firewall` resource located in the Gardener `Seed` or the metal-apiserver node network entity, while the CWNPs should be fetched and applied from a given kubeconfig (the `Shoot` Kubeconfig in the Gardener case).
This configuration file is intended to be injected during firewall creation through the userdata along with potential source connection credentials.

```yaml
# the name of the firewall, defaulted to the hostname
name: best-firewall-ever

sources:
  seed:
    kubeconfig: /path/to/seed.yaml # current gardener behavior
    namespace: shoot--proj--name
  shoot:
    kubeconfig: /path/to/shoot.yaml # current gardener behavior
    namespace: firewall
  metal:
    url: https://metal-api
    hmac: some-hmac
    type: Metal-View
    projectID: abc
  static:
    # static should mirror all information provided by the metal or seed/shoot sources
    firewall: # optional
      controllerURL: https://...
    cwnp:
      egress: []
      ingress: []

# all sub-controllers running on the firewall
# each can be configured independently
controllers:
  # this is the base controller
  firewall:
    source: seed # or: metal, static

    # these are optional: when not provided, they are disabled
    selfUpdate:
      enabled: true
    droptailer:
      enabled: true

  # these are optional: when not provided, they are disabled
  service:
    source: shoot # or: metal, static
  cwnp:
    source: shoot # or: metal, static
  monitor:
    source: shoot # currently only shoot is supported
```

The existing behavior of the firewall-controller writing into `/etc/nftables/firewall-controller.v4` is not changed. The different controller configuration sources are internally treated in the same way as before. The `static` source can be used to prevent the firewall-controller from crashing and consistently providing a static ruleset. This might be interesting for metal-stack native use cases or environments where the metal-api cannot be accessed.

There must be one central nftables-rule-file-controller that is notified and triggered by all other controllers that contribute to the nftables configuration.

For example, in order to maintain the existing Gardener integration, the configuration file for the firewall-controller will look like this:

```yaml
name: shoot--abc--cluster-firewall-def
sources:
  seed:
    kubeconfig: /etc/firewall-controller/seed.yaml
    namespace: shoot--abc--cluster
  shoot:
    kubeconfig: /etc/firewall-controller/shoot.yaml
    namespace: firewall

controllers:
  firewall:
    source: seed
    
    selfUpdate:
      enabled: true
    droptailer:
      enabled: true

  service:
    source: shoot
  cwnp:
    source: shoot
  monitor:
    source: shoot
```

Plain metal-stack users might use a configuration like this:

```yaml
name: best-firewall-ever

sources:
  metal:
    url: https://metal-api
    hmac: some-hmac
    type: Metal-View
    projectID: abc
    
controllers:
  firewall:
    source: metal
    selfUpdate:
      enabled: true
    droptailer:
      enabled: true

  cwnp:
    # firewall rules stored in firewall entity
    # potential improvement would be to attach the rules to the node network entity
    # be aware that the firewall and private networks are immutable
    # eventually we introduce a firewall ruleset entity
    source: metal
```

In highly restricted environments that cannot access metal-api the static source could be used:

```yaml
name: most-restricted-firewall-ever

sources:
  static:
    firewall:
      controllerURL: https://...
    cwnp:
      egress: []
      ingress: []

controllers:
  firewall:
    source: static

  cwnp:
    source: static
```

### Non-Goals

- Resolving the missing differentiation between users and administrators by letting users pass userdata and SSH keys to the firewall creation.
  - This is even more related to [MEP-4](../MEP4/README.md) than this MEP.

### Advantages

- Offers a native metal-stack solution that improves managing firewalls for users by adding dynamic reconfiguration through the metal-api
  - e.g., in the mini-lab, users can now allocate a machine, then an IP address and announce this IP from the machine without having to re-create the firewall but by adding a firewall rule to the metal-api.
- Improve consistency throughout the API (firewall rules would reflect what is persisted in metal-api).
- Other providers like Cluster API can leverage this approach, too.
- It can contribute to solving the shoot migration issue (in Cluster API case the `clusterctl move` for firewall objects)
  - For Gardener takes the seed out of the equation (of which the kubeconfig changes during shoot migration)
  - However: Things like egress rules, rate limiting, etc. are currently not part of the firewall or network entity in the metal-api. These would need to be added to one of them.
- Potentially resolve the issue that end-users can manipulate accounting data of the firewall through the `FirewallMonitor`
  - for this we would need to be able to report traffic data to metal-api

### Caveats

- Metal-View access is too broad for firewalls. Mitigated by [MEP-4](../MEP4/README.md).
- Polling of the firewall-controller is bad for performance. Mitigated by [MEP-4](../MEP4/README.md).

### Firewall Controller Manager

Currently the firewall-controller-manager expects the creators of a `FirewallDeployment` to use the defaulting webhook that is tailored to the Gardener integration in order to generate `Firewall.spec.userdata` or to override it manually. Currently `Firewall.spec.userdata` will never be set explicitly.

Instead we'd like to propose `Firewall.spec.userdataContents` which will replace the old `userdata`-string by a typed data structure. The FCM will do the heavy lifting while the `FirewallDeployment` creator decides what should be configured.

```yaml
kind: FirewallDeployment
spec:
  template:
    spec:
      userdataContents:
      - path: /etc/firewall-controller/config.yaml
        content: |
          ---
          sources:
            static: {}
          controllers:
            firewall:
              source: static
      - path: /etc/firewall-controller/seed.yaml
        secretRef:
            name: seed-kubeconfig
            generateFirewallControllerKubeconfig: true
      - path: /etc/firewall-controller/shoot.yaml
        secretRef:
            name: shoot-kubeconfig
```

### Gardener Extension Provider Metal Stack

The GEPM should be migrated to the new `Firewall.spec.userdataContents` field.

### Cluster API Provider Metal Stack

![architectural overview](firewall-for-capms-overview.drawio.svg)

In Cluster API there are essentially two main clusters: the management cluster and the workload cluster while the CAPMS takes in the role of the GEPM.
Typically a local bootstrap cluster is created in KinD which acts as the management cluster. It creates the workload cluster. Thereafter the ownership of the workload cluster is typically moved (using `clusterctl move`) to a different cluster which will then become the management cluster.
The new management cluster might actually be the workload cluster itself.

In contrast to Gardener, Cluster API aims to be less opinionated and minimal. It is common practice to not install any non-required components or CRDs into the workload cluster by default. Therefore we cannot expect custom resources like `ClusterwideNetworkPolicy` or `FirewallMonitor` to be installed in the workload cluster but strongly recommend our users to do it. Therefore it's the responsibility of the operator to tell [cluster-api-provider-metal-stack](https://github.com/metal-stack/cluster-api-provider-metal-stack) the kubeconfig for the cluster where these CRDs are installed and defined in.

A viable configuration for a `MetalStackCluster` that generates firewall rules based of `Service` type `LoadBalancer` and `ClusterwideNetworkPolicy` and expects them to be deployed in the workload cluster is shown below. The `FirewallMonitor` will be reported into the same cluster.

```yaml
kind: MetalStackCluster
metadata:
    name: ${CLUSTER_NAME}
spec:
    firewallTemplate:
        userdataContents:
          - path: /etc/firewall-controller/config.yaml
            secretName: ${CLUSTER_NAME}-firewall-controller-config

          - path: /etc/firewall-controller/workload.yaml
            # this is the kubeconfig generated by kubeadm
            secretName: ${CLUSTER_NAME}-kubeconfig
---
kind: Secret
metadata:
    name: ${CLUSTER_NAME}-firewall-controller-config
stringData:
    controllerConfig: |
        ---
        name: ${CLUSTER_NAME}-firewall

        sources:
          metal:
            url: ${METAL_API_URL}
            hmac: ${METAL_API_HMAC}
            type: ${METAL_API_HMAC_TYPE}
            projectID: ${METAL_API_PROJECT_ID}
          shoot:
            kubeconfig: /etc/firewall-controller/workload.yaml
            namespace: firewall
    
        controllers:
          firewall:
            source: metal
            selfUpdate:
              enabled: true
            droptailer:
              enabled: true

          service:
            source: shoot
          cwnp:
            source: shoot
          monitor:
            source: shoot
```

Here the firewall-controller-config will be referenced by the `MetalStackCluster` as a `Secret`. Please note that the `Secret`s in `userdataContents` will not be fetched and will directly be passed to the `FirewallDeployment`. At first the reconciliation of it in the FCM will fail due to the missing Kubeconfig secret. After the `MetalStackCluster` has been marked as ready, CAPI will create this missing secret. Effectively the firewall and initial control plane node should be created at the same time.

This approach allows maximum flexibility as intended by Cluster API and is still able to provide robust rolling updates of firewalls.

An advanced use case of this flexibility would be a management cluster, that is in charge of multiple workload clusters. Where one workload cluster acts as a monitoring or tooling cluster, receives logs and the firewall monitor for the other workload clusters. The CWNPs could be defined here, all in a separate namespace.

#### Cluster API Caveats

When the cluster is pivoted and reconciles its own firewall, a malfunctioning firewall prevents the cluster from self-healing and requires manual intervention by creating a new firewall. This is an inherent problem of the cluster-api approach. It can be circumvented by using an extra cluster to manage workload clusters.

In the current form of this approach firewalls and therefore the firewall egress and ingress rules are managed by the cluster operators that manage the cluster-api resources.
Hence it will not be possible to gain a fine-grained control over every cluster operator's choices from a central ruleset at the level of metal-stack firewalls.
In case this control surfaces as a requirement, it would need to be implemented in a firewall external to metal-stack.

## Roadmap

In general this proposal is not thought to be implemented in one batch. Instead an incremental approach is required.

1. Enhance firewall-controller

    - Reduce coupling between controllers
    - Introduce controller config
    - Abstract module to write into distinct nftable rules for every controller
    - Implement `sources.static`, but not `sources.metal`
    - GEPM should set `FirewallDeployment.spec.template.spec.userdataContents`

2. Allow Cluster API to use the FCM with static ruleset

    - Add `firewall.metal-stack.io/paused` annotation (managed by CAPMS during `clusterctl move`, theoretically useful for Gardener shoot migration as well to avoid shallow deletion).
    - Reconcile multiple `FirewallDeployment` resources across multiple namespaces. For Gardener the old behavior of reconciling only one namespace should persist.
    - Allow setting the `firewall.metal-stack.io/no-controller-connection` annotation through the `FirewallDeployment` (either through the template or inheritance).
    - Add `MetalStackCluster.spec.firewallTemplate`.
    - Make `MetalStackCluster.spec.nodeNetworkID` optional if `spec.firewallTemplate` given.

3. Add `sources.metal` as configuration option.

    - Allow updates of firewall rules in the metal-apiserver.
    - Depends on [MEP-4](../MEP4/README.md) metal-apiserver progress

4. Potentially migrate the GEPM to use `sources.metal`
