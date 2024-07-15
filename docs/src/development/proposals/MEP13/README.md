# IPv6 Support

IPv6 support is required to be able to create Kubernetes clusters with either IPv6 single- or dual-stack enabled.
With immanent shortage of IPv4 addresses the need to be able to use IPv6 increased.

Full IPv6 dual-stack Support was added to Kubernetes with v1.23 as stable.

Gardener on the other hand does not yet have full IPv6 dual-stack support. See: https://github.com/gardener/gardener/issues/7051

metal-stack manages CIDRs and IP addresses with the [go-ipam](https://github.com/metal-stack/go-ipam) library, which gained full IPv6 Support already in 2021 (see https://metal-stack.io/blog/2021/02/ipv6-part1).
But this was only the foundation, to get full IPv6 support for all aspects which are managed by metal-stack.io, further work needs to be done.

## General Decisions

### Networks

Currently, metal-stack organizes CIDRs/prefixes into a `network' resource in the metal-api. A network can consist of multiple CIDRs from the same address family. For example, if an operator wants to provide Internet connectivity to provisioned machines, they can start with small network CIDRs. The number of managed network prefixes can then be expanded as needed over time.

With IPv6 we have to choose between two options:

#### Network per Address Family

This means that we allow networks with CIDRs from one address family only, one for IPv4 and one for IPv6.

The machine creation process will not change if the machine only needs to be either IPv4 or IPv6 addressable.
But if on the other side, the machine need to be able to connect to both address families, the machine creation needs to specify two networks, one for IPv4 and one for IPv6.
Also there will be 2 distinct VRF IDs for every network with a different address family.

#### Network with both Address Families

Make a network dual address family capable, that means that you can add multiple cidrs from both address families to one network
Then the machine creation will stay the same for the single stack and dual-stack case, but the ip address allocation from one network must return a pair of ip addresses if the network is dual-stack.
