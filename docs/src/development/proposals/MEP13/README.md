# Dualstack Support

Dualstack support is required to be able to create Kubernetes clusters with either IPv6 single- or dual-stack enabled.
With immanent shortage of IPv4 addresses the need to be able to use IPv6 increased.

Full IPv6 dual-stack Support was added to Kubernetes with v1.23 as stable.

Gardener have full IPv6 dual-stack support since v1.109

metal-stack manages CIDRs and IP addresses with the [go-ipam](https://github.com/metal-stack/go-ipam) library, which gained full IPv6 Support already in 2021 (see [https://metal-stack.io/blog/2021/02/ipv6-part1](https://metal-stack.io/blog/2021/02/ipv6-part1) ).
But this was only the foundation, to get full IPv6 support for all aspects which are managed by metal-stack.io, further work needs to be done.

## General Decisions

### Networks

Currently, metal-stack organizes CIDRs/prefixes into a `network' resource in the metal-api. A network can consist of multiple CIDRs from the same address family. For example, if an operator wants to provide Internet connectivity to provisioned machines, they can start with small network CIDRs. The number of managed network prefixes can then be expanded as needed over time.

With Dualstack we have to choose between two options:

#### Network per Address Family

This means that we allow networks with CIDRs from one address family only, one for IPv4 and one for IPv6.

The machine creation process will not change if the machine only needs to be either IPv4 or IPv6 addressable.
But if on the other side, the machine need to be able to connect to both address families, the machine creation needs to specify two networks, one for IPv4 and one for IPv6.
Also there will be 2 distinct VRF IDs for every network with a different address family.

#### Network with both Address Families

Make a network dual address family capable, that means that you can add multiple cidrs from both address families to one network
Then the machine creation will stay the same for the single stack and dual-stack case, but the ip address allocation from one network must return a pair of ip addresses if the network is dual-stack.
It would also be possible to return by default only the IPv4 ip address when allocate one, but add the possibility to specify the addressfamily. With this the ip address allocation can be called for both addressfamilies if the machine needs to be dual-stack attached. This would not break the existing api, but enables existing extensions to add dual-stack support in a easy way.
To prevent additional checking what addressfamilies are available in this network during a ip allocation call, we could store the addressfamilies in the network.

#### Decision

The decision was made to go with the later because we think this is the most flexible way to support dualstack machines and kubernetes clusters as well as single stack with the least amount of modifications on the networking side.

### Not considered

- isolated clusters

### Examples

To illustrate the the usage we start by creating a tenant super network which has both address families:

```yaml
---
id: tenant-super-network-mini-lab
name: Project Super Network
description: Super network of all project networks
addressfamilies:
  IPv4: true
  IPv6: true
defaultchildprefixlength:
  IPv4: 22
  IPv6: 64
nat: false
partitionid: mini-lab
prefixes:
- 10.0.0.0/12
- 2001:db8:1234:/48
privatesuper: true
underlay: false
```

In order to create this network, we simple call:

`metalctl network create -f tenant-super.yaml`

This is usually done during the initial setup of the environment.

Next step is to allocate a tenant network where the machines of a project can be placed:

`metalctl network allocate --partition fra --project bla --name tenant-nw`

FIXME: actually no dualstack tenant network allocated if super is dualstack, but should be

- name tenant-nw
- 10.214.0.0/22
- 2001:db8:1234:a:/64

machine:

- 10.214.0.1/32: was allocated with: metalctl network ip allocate --network tenant-nw
- 2001:db8:1234:a::1/128: was allocated with: metalctl network ip allocate --network tenant-nw --addressfamily ipv6

firewall:

- 10.214.0.2/32
- 2002:db8:1234:a::1/128

Firewall and Worker Nodes get their own dedicated IPv6 cidr.

Internet Super Network IPv6

- name: internetv6
- 2002:db8:1234:a:/48

Internet Shared Network

- 212.34.85.0/24

tenant super network:

- 10.0.0.0/12
- 2001:db8:1234:/48

internet tenant network:

- name: tenant-internet-v6
- 2002:a:1:/58: metalctl network allocate --network internetv6

machine: no nat for ipv6

- 10.214.0.1/32: was allocated with: metalctl network ip allocate --network tenant-nw
- 2002:a:1:1/128: was allocated with: metalctl network ip allocate --network tenant-internet-v6

firewall:

- 10.214.0.2/32: was allocated with: metalctl network ip allocate --network tenant-nw
- 2002:a:1:2/128: was allocated with: metalctl network ip allocate --network tenant-internet-v6
