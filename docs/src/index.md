# Overview

metal-stack is a software to provide physical servers on demand. It is a fully-automated provisioning framework for bare metal machines. To categorize this product, we commonly use the terminology _metal-as-a-service (MaaS)_ or _bare metal cloud_.

```@index
```

## Use-Cases

The major intent to initiate metal-stack was to build a framework that provides [Kubernetes](https://kubernetes.io/) (K8s) as a service (KaaS) in on-premise environments.

Running this on-premise has several benefits:

- Data sovereignty
- Better price/performance ratio
- Easier connectivity to existing company networks

From the very beginning, the machines provided by metal-stack are provided with the intention to run software managed by K8s. Reason for this is that K8s makes the bare metal approach shine and mitigates the problems that come with the approach (see [Why bare metal?](#why-bare-metal)).

metal-stack itself is typically deployed on Kubernetes as well. However, there are no specific dependencies of metal-stack running in a Kubernetes cluster. It exposes a traditional REST API that can be used for managing bare metal machines.

## Why Do You Need a Cloud?

We are clearly aiming at a fully-automated lifecycle for K8s clusters. The speed in which we want to provide K8s to a user makes this product very attractive. The time saving compared to providing machines and Kubernetes by hand are significant. We actually want to be able to compete with offers of public cloud providers, especially regarding speed and usability.

## Why Bare Metal?

The bare metal approach is especially attractive for the purpose of running K8s on top of it. Bare metal has several advantages over virtualized environments and overcomes several of the drawbacks of virtual machines.

1. Virtual environment drawbacks
  - [Spectre and Meltdown](https://meltdownattack.com/) can only be mitigated with a "cluster per tenant" approach
  - Missing isolation of multi-tenant change impacts
  - Licensing restrictions
  - "Noisy-neighbor" issues

2. Advantages of a metal-as-a-service platform
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

In the end, we have come to the conclusion that most of the drawbacks of bare metal machines can be mitigated when running K8s on the machines. K8s will take care of high-availability in case of hardware failures and also supervises machine resources. We are certain that the chosen approach can satisfy the needs of the future users to a higher degree than virtual machines could do.

## Roadmap

Coming soon.
