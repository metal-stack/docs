# Flavors of metal-stack

While metal-stack itself provides access to manage resources like machines, networks and ip addresses, it does not provide any higher abstractions on top when used on its own.

As modern infrastructure and cloud native applications are designed with Kubernetes in mind, we provide two different layers on top of metal-stack to provide provisioning of clusters.

## Plain

Regardless which flavor of metal-stack you use, it is always possible to manually provision machines, networks and ip addresses. This is the most basic way of using metal-stack and is very similar to how traditional bare metal infrastructures are managed.

Using plain metal-stack without additional layer was not a focus in the past. Therefore firewall and role management might be premature. These will be addressed by [MEP-4](../developers/proposals/MEP4/README.md) and [MEP-16](../developers/proposals/MEP16/README.md) in the future.

## Gardener

We recommend using metal-stack with our [Gardener integration](../concepts/kubernetes/gardener.md), which allows to manage Kubernetes clusters at scale. This integration is battle proof, well documented, used by many organizations in production and build on top of the open-source project [Gardener](https://gardener.cloud/).

When compared to our Cluster API integration, this is more and provides a lot more features and stability. Clusters can more easily be created and managed.

## Cluster API

Our [Cluster API integration](https://github.com/metal-stack/cluster-api-provider-metal-stack) is a more experimental approach to provide Kubernetes clusters with metal-stack. It is based on the [Cluster API](https://cluster-api.sigs.k8s.io/) project.

Resulting clusters are as minimal as possible and need to be configured manually after creation. With this approach there is no concept of service clusters. Each cluster is manually created and managed.
