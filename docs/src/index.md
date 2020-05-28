# metal-stack Documentation

metal-stack is a software that provides an API for provisioning and managing physical servers. It is a fully-automated provisioning framework for bare metal machines. To categorize this product, we commonly use the terminology _metal-as-a-service (MaaS)_ or _bare metal cloud_.

```@contents
Pages = ["index.md"]
Depth = 5
```

## Use-Cases

The major intent to initiate metal-stack was to build a framework that provides an on-premise machine infrastructure for [Kubernetes](https://kubernetes.io/) (K8s) as a service (KaaS). But of course you can also use metal-stack only for multi-tenant-capable machine provisioning as well in your data center.

Running on-premise has several benefits:

- Full data sovereignty
- Typically better price/performance ratio than hyperscalers (especially the larger your environments are)
- Easier connectivity to existing company networks

metal-stack itself is typically deployed on Kubernetes as well. However, there are no specific dependencies of metal-stack running in a Kubernetes cluster. It exposes a traditional REST API that can be used for managing bare metal machines.

## Kubernetes Integration

In partnership with the open-source project [Gardener](https://gardener.cloud/), we provision Kubernetes clusters on metal-stack at scale. From the perspective of the Gardener, the metal-stack is just another cloud provider.

We are clearly aiming at a fully-automated lifecycle for K8s clusters. The time saving compared to providing machines and Kubernetes by hand are significant. We actually want to be able to compete with offers of public cloud providers, especially regarding speed and usability.

## Why Bare Metal?

Bare metal has several advantages over virtualized environments and overcomes several of the drawbacks of virtual machines.

1. Virtual environment drawbacks
   - [Spectre and Meltdown](https://meltdownattack.com/) can only be mitigated with a "cluster per tenant" approach
   - Missing isolation of multi-tenant change impacts
   - Licensing restrictions
   - "Noisy-neighbor" issues
1. Advantages of a metal-as-a-service platform
   - High and guaranteed performance (especially disk i/o)
   - Reduced stack depth (Host -> VM -> Application vs. Host -> Container) => reduced attack surface, cost/performance gain, no VM live-migrations
   - No need for a central storage system: Local storage governed by K8s to reduce storage costs
   - Bigger hardware configuration possible (hypervisors have restrictions, e.g. it is not possible to assign all CPUs to a single VM)
   - K8s ships with "enterprise" features (performance, availability, scalability) on commodity hardware

Beside these benefits there are also several disadvantages of metal-as-a-service platforms to consider:

- Hardware defects have direct impact (should be considered by design) and can not be mitigated by live-migration as in virtual environments
- Not many "providers" to choose from
- Bare metal provisioning is slower than provisioning a VM
- Capacity planning is more difficult (no resource overbooking possible)
- Higher "AfA"-costs

In the end, we have come to the conclusion that most of the drawbacks of bare metal machines can be mitigated best when running K8s on the machines. K8s will take care of high-availability in case of hardware failures and also supervises machine resources. We are certain that the chosen approach can satisfy the needs of the future users to a higher degree than virtual machines could do.

## Roadmap

Coming soon.
