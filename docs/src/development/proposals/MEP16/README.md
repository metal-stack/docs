# Firewall Support for Cluster API Provider

Currently the creation and management of firewalls is out of scope for the [Cluster API Provider metal-stack](https://github.com/metal-stack/cluster-api-provider-metal-stack), or in short CAPMS. In practice this requires operators to create the firewall and therefore also the node network before generating the cluster.
When either the firewall rules, the firewall image or the firewall machine size change, the current approach also requires the operator to manually roll the firewall by creating a new one and deleting the old firewall. 

To gain a production ready implementation for Cluster API to automatically manage the deployment of firewalls, it makes sense to build on top of prior art.
In case of Gardener on metal-stack the [Firewall Controller Manager](https://github.com/metal-stack/firewall-controller-manager), or short fcm, is used. 

## Overview

![architectural overvier](firewall-for-capms-overview.svg)

The CAPMS controller manager should now create the node network if needed. And when a firewall template exists for the cluster, a firewall deployment should be created and updated on every change.

The fcm should now observe all firewall deployments across all namespaces. It then creates firewall sets and later firewalls. It already handles and implements rolling updates.

## Implementation

During reconciliation the CAPMS controller manager has a look at `MetalStackCluster.Spec.NodeNetworkID`. If it is not yet set, the node network should created and patched back into the spec. Then the manager should move to the `MetalStackCluster.Spec.FirewallTemplate`. When set, it should create or update the matching `FirewallDeployment` according to the nested data like the image, networks, size or the `FirewallDeployment.Spec.Template.InitialRuleSet`.

From here on the fcm will take over to reconcile all `FirewallDeployment`s. Currently it only watches a specific namespace and needs to be adapted to be capable of operating on all namespaces instead. Also initial firewall rule sets need to be implemented.

When the operator installs Cluster API including CAPMS into their cluster, `clusterctl init --infrastructure metal-stack` needs to include the fcm custom resources and optionally its controller deployment to be able to reconcile firewalls.

When generating a new cluster using `clusterctl generate cluster --infrastructure metal-stack cluster-name`, this should also generate a firewall entry including some basic firewall rules.

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha1
kind: MetalStackCluster
metadata:
  name: cluster-name
  namespace: default
spec:
  projectID: some-project-id
  partition: partition
  nodeNetworkID: node-network-id # now optional if firewall given
  firewallTemplate:
    size: machine-size
    image: firewall-ubuntu
    networks: [] # the node-network-id will be appended automatically
    initialRuleSet:
      ingress:
      - comment: allow incoming https
        protocol: tcp
        ports: [443]
        from: [0.0.0.0/0]
      egress:
      - comment: allow outgoing https
        protocol: tcp
        ports: [443]
        to: [0.0.0.0/0]
      # additional entries for dns, ssh and ntp required
```

Cluster API allows to move the resource and therefore the control over the bootstrapped workload cluster. As part of this process `clusterctl` marks the cluster as paused. Providers like CAPMS need to obey the pause and may not reconcile during this time period to avoid loss of infrastructure and data.

When using the fcm in this context, it should also obey this rule. But in order to keep the fcm separated from cluster api internals, we'd like to propose the `firewall.metal-stack.io/paused` annotation to pause the reconciliation. Managing this pause annotation on the `FirewallDeployment` is in the responsibility of the CAPMS controller manager.

This annotation still needs to be propagated to nested resources like `FirewallSet` and `Firewall`.

Furthermore Cluster API also requires to have an unbroken chain of owner references. In practice this means `Firewall` is owned by `FirewallSet` which is in turn owned by `FirewallDeployment`. This is a [Kubernetes feature](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/) and good practice anyways.

## Affected Components

For some working items, we already created proof of concept PRs, which might need to be split up and are not yet production ready.

- Firewall Controller Manager
  - must be configured to watch all namespaces for `FirewallDeployment` [fcm#66](https://github.com/metal-stack/firewall-controller-manager/pull/66)
  - initial firewall rules needs to be implemented [fcm#64](https://github.com/metal-stack/firewall-controller-manager/pull/64)
  - the annotations of the `FirewallDeployment` need to be propagated down to the `FirewallSet` and `Firewall`
  - needs to introduce and implement the `firewall.metal-stack.io/paused` annotation
  - set owner references to `FirewallSet` and `Firewall`
- Cluster API Controller Manager
  - the `FirewallDeployment` pause annotation needs to be managed
  - the `FirewallDeployment` resource should be created if template set [CAPMS#82](https://github.com/metal-stack/cluster-api-provider-metal-stack/pull/82)
  - management of SSH keys for machines and firewalls [CAPMS#82](https://github.com/metal-stack/cluster-api-provider-metal-stack/pull/82)
  - cluster-template
    - needs to install CRDs for the FCM in order to be respected during moves [CAPMS#82](https://github.com/metal-stack/cluster-api-provider-metal-stack/pull/82)
    - eventually also install the FCM itself
  - `MetalStackCluster` resource definition
    - add `MetalStackCluster.Spec.FirewallTemplate`
    - make `Spec.NodeNetworkID` optional if `Spec.FirewallTemplate` given

## Caveats and Organizational Implications

When the cluster is pivoted and reconciles its own firewall, a malfunctioning firewall prevents the cluster from self-healing and requires manual intervention by creating a new firewall. This is an inherent problem of the cluster-api approach. It can be circumvented by using an extra cluster to manage workload clusters.

In the current form of this approach firewalls and therefore the firewall egress and ingress rules are managed by the cluster operators that manage the cluster-api resources.
Hence it will not be possible to gain a fine-grained control over every cluster operator's choices from a central ruleset at the level of metal-stack firewalls.
In case this control surfaces as a requirement, it would need to be implemented in a firewall external to metal-stack.
