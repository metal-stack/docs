# Welcome to the metal-stack docs!

metal-stack is a open source software that provides an API for provisioning and managing physical servers in the data center. To categorize this product, we use the terms _Metal-as-a-Service (MaaS)_ or _bare metal cloud_.

From the perspective of a user, the metal-stack does not feel any different from working with a conventional cloud provider. Users manage their resources (machines, networks and ip addresses, etc.) by themselves, which effectively turns your data center into an elastic cloud infrastructure.

The major difference to other cloud providers is that compute power and data reside in your own data center.

```@contents
Pages = ["index.md"]
Depth = 5
```

## Releases

````@eval
using Docs

version = releaseVersion()

t = raw"""
Your are currently reading the documentation for the metal-stack `%s` release.
"""

markdownTemplate(t, version)
````

Releases and integration tests are published through our [release repository](https://github.com/metal-stack/releases). You can also find the [release notes](https://github.com/metal-stack/releases/releases) for this metal-stack version in there. The release notes contain information about new features, upgrade paths and bug fixes.

If you want, you can sign up at our Slack channel where we are announcing every new release. Often, we provide additional information for metal-stack administrators and adopters at this place, too.

## Why metal-stack?

Before we started with our mission to implement the metal-stack, we decided on a couple of key characteristics and constraints that we think are unique in the domain (otherwise we would definitely have chosen an existing solution).

We hope that the following properties appeal to you as well.

### On-Premise

Running on-premise gives you data sovereignty and usually a better price / performance ratio than with hyperscalers — especially the larger you grow your environment. Another benefit of running on-premise is an easier connectivity to existing company networks.

### Fast Provisioning

Provisioning bare metal machines should not feel much different from virtual machines. metal-stack is capable of provisioning servers in less than a minute. The underlying network topology is based on BGP and allows announcing new routes to your host machines in a matter of seconds.

### No-Ops

Part of the metal-stack runs on dedicated switches in your data center. This way, it is possible to automate server inventorization, permanently reconcile network configuration and automatically manage machine lifecycles. Manual configuration is neither required nor wanted.

### Security

Our networking approach was designed for highest standards on security. Also, we enforce firewalling on dedicated tenant firewalls before users can establish connections to other networks than their private tenant network. API authentication and authorization is done with the help of OIDC.

### API driven

The development of metal-stack is strictly API driven and offers self-service to end-users. This approach delivers the highest possible degree of automation, maintainability and performance.

### Ready for Kubernetes

Not only does the metal-stack run smoothly on [Kubernetes](https://kubernetes.io/) (K8s). The major intent of metal-stack has always been to build a scalable machine infrastructure for _Kubernetes as a Service (KaaS)_. In partnership with the open-source project [Gardener](https://gardener.cloud/), we can provision Kubernetes clusters on metal-stack at scale.

From the perspective of the Gardener, the metal-stack is just another cloud provider. The time savings compared to providing machines and Kubernetes by hand are significant. We actually want to be able to compete with offers of public cloud providers, especially regarding speed and usability.

Of course, you can use metal-stack only for machine provisioning as well and just put something else on top of your metal infrastructure.

### Open Source

The metal-stack is open source and free of constraints regarding vendors and third-party products. The stack is completely built on open source products. We have a community actively working on the metal-stack, which can assist you delivering all reasonable features you are gonna need.

## Why Bare Metal?

Bare metal has several advantages over virtual environments and overcomes several drawbacks of virtual machines. We also listed drawbacks of the bare metal approach. Bare in mind though that it is still possible to virtualize on bare metal environments when you have your stack up and running.

### Virtual Environment Drawbacks

- [Spectre and Meltdown](https://meltdownattack.com/) can only be mitigated with a "cluster per tenant" approach
- Missing isolation of multi-tenant change impacts
- Licensing restrictions
- Noisy-neighbors

### Bare Metal Advantages

- Guaranteed and fastest possible performance (especially disk i/o)
- Reduced stack depth (Host / VM / Application vs. Host / Container)
  - Reduced attack surface
  - Lower costs, higher performance
  - No VM live-migrations
- Bigger hardware configurations possible (hypervisors have restrictions, e.g. it is not possible to assign all CPUs to a single VM)

### Bare Metal Drawbacks

- Hardware defects have direct impact (should be considered by design) and can not be mitigated by live-migration as in virtual environments
- Capacity planning is more difficult (no resource overbooking possible)
