# Introduction

metal-stack is a software that provides an API for provisioning and managing physical servers in the data center. To categorize this product, we commonly use the terms _Metal-as-a-Service (MaaS)_ or _bare metal cloud_.

From the perspective of a user, the metal-stack does not feel different from working with any other cloud provider. Users manage their resources (machines, networks and ip addresses, etc.) by themselves, turning your data center into an elastic cloud infrastructure. The major difference to other cloud providers is that compute power and data reside in your own data center.

```@contents
Pages = ["index.md"]
Depth = 5
```

## Key Characteristics

### On-Premise

Running on-premise gives you data sovereignty and usually a better price/performance ratio than with hyperscalers (especially the larger your environment gets). Another benefit of running on-premise is an easier connectivity to existing company networks.

### Fast Provisioning

Provisioning bare metal machines should not feel much different from virtual machines. And to be honest: Slow environments are no fun to work with. metal-stack is capable of provisioning servers in less than a minute. The underlying network topology is based on BGP and allows announcing new routes to your host machines in a matter of seconds.

### No-Ops

Part of the metal-stack runs on dedicated switches in your data center. This way, it is possible to automate server inventorization, permanently reconcile network configuration and automatically manage machine lifecycles. Manual configuration is neither required nor wanted.

### Security

Our networking approach was designed for highest standards on security. Also, we enforce firewalling on dedicated tenant firewalls before users can establish connections to other networks than their private tenant network.

### API driven

The development of metal-stack is strictly API driven and offers self-service to end-users. This approach delivers the highest possible degree of automation, maintainability and performance.

### Ready for Kubernetes

Not only does the metal-stack run smoothly on [Kubernetes](https://kubernetes.io/) (K8s). The major intent of metal-stack has always been to build a scalable machine infrastructure for _Kubernetes as a Service (KaaS)_. In partnership with the open-source project [Gardener](https://gardener.cloud/), we can provision Kubernetes clusters on metal-stack at scale.

From the perspective of the Gardener, the metal-stack is just another cloud provider. The time savings compared to providing machines and Kubernetes by hand are significant. We actually want to be able to compete with offers of public cloud providers, especially regarding speed and usability.

Of course, you can use metal-stack only for machine provisioning as well. Literally, you can get very creative with what you stack onto metal.

### Open Source

The metal-stack is open source and free of constraints regarding vendors and third-party products. The stack is completely built on open source products. We have an open community actively working on the metal-stack, which can assist you delivering all reasonable features you are gonna need.

## Why Bare Metal?

Bare metal has several advantages over virtual environments and overcomes several drawbacks of virtual machines.

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

### Conclusion

In the end, we have come to the conclusion that most of the drawbacks of bare metal machines can be mitigated best when running K8s on the machines. K8s will take care of high-availability in case of hardware failures and also supervises machine resources. We are certain that the chosen approach can satisfy the needs of the future users to a higher degree than virtual machines could do.

## Roadmap

Coming soon.
