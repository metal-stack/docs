# Introduction

metal-stack is a software that provides an API for provisioning and managing physical servers in a data center. To categorize this product, we commonly use the terminology _metal-as-a-service (MaaS)_ or _bare metal cloud_.

```@contents
Pages = ["index.md"]
Depth = 5
```

## Key Properties

### On-Premise

Running on-premise gives you full data sovereignty and usually a better price/performance ratio than with hyperscalers (especially the larger your environment gets). Another advantage of running on-premise is the easier connectivity to existing company networks.

### Fast Provisioning

Machine provisioning of bare metal machines should not feel much different from virtual machines. metal-stack is capable of provisioning servers in less than a minute.

### No-Ops

Part of the metal-stack runs on dedicated switches in your data center. This way, it is possible to automate server inventorization, network configuration and machine lifecycles.

### Ready for Kubernetes

Not only does the metal-stack run smoothly on Kubernetes. The major intent of metal-stack has always been to build an elastic machine infrastructure for [Kubernetes](https://kubernetes.io/) (K8s) as a service (KaaS). In partnership with the open-source project [Gardener](https://gardener.cloud/), we provision Kubernetes clusters on metal-stack at scale.

From the perspective of the Gardener, the metal-stack is just another cloud provider. The time savings compared to providing machines and Kubernetes by hand are significant. We actually want to be able to compete with offers of public cloud providers, especially regarding speed and usability.

Of course, you can use metal-stack only for machine provisioning as well.

### Open Source

The metal-stack is open source and free of constraints regarding vendors and third-party products. The stack is completely built on open source products. We have an open community actively working on the metal-stack, which can assist you delivering all reasonable features you are gonna need.

## Why Bare Metal?

Bare metal has several advantages over virtualized environments and overcomes several drawbacks of virtual machines.

### Virtual Environment Drawbacks

- [Spectre and Meltdown](https://meltdownattack.com/) can only be mitigated with a "cluster per tenant" approach
- Missing isolation of multi-tenant change impacts
- Licensing restrictions
- Noisy-neighbors

### Bare Metal Advantages

- Guaranteed and fastest possible performance (especially disk i/o)
- Reduced stack depth (Host -> VM -> Application vs. Host -> Container)
  - Reduced attack surface
  - Lower costs, higher performance
  - No VM live-migrations
- Bigger hardware configurations possible (hypervisors have restrictions, e.g. it is not possible to assign all CPUs to a single VM)

### Bare Metal Drawbacks

- Hardware defects have direct impact (should be considered by design) and can not be mitigated by live-migration as in virtual environments
- Capacity planning is more difficult (no resource overbooking possible)
- Higher "AfA"-costs

### Conclusion

In the end, we have come to the conclusion that most of the drawbacks of bare metal machines can be mitigated best when running K8s on the machines. K8s will take care of high-availability in case of hardware failures and also supervises machine resources. We are certain that the chosen approach can satisfy the needs of the future users to a higher degree than virtual machines could do.

## Roadmap

Coming soon.
