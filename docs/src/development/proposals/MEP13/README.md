# Dual-stack Support

dual-stack support is required to be able to create Kubernetes clusters with either IPv6 single-stack or dual-stack enabled.
With the inherent scarcity of IPv4 addresses, the need to be able to use IPv6 has increased.

Full IPv6 dual-stack support was added to Kubernetes with v1.23 as stable.

Gardeners have had full IPv6 dual-stack support since `v1.109`.

metal-stack manages CIDRs and IP addresses with the [go-ipam](https://github.com/metal-stack/go-ipam) library, which already got full IPv6 support in 2021 (see [https://metal-stack.io/blog/2021/02/ipv6-part1](https://metal-stack.io/blog/2021/02/ipv6-part1)).
But this was only the foundation, more work needs to be done to get full IPv6 support for all aspects managed by metal-stack.io.

## General Decisions

For the general decision we do not look at the isolated clusters feature for now as this would make the solution even more complex and we want to introduce IPv6 in smaller steps to the users.

### Networks

Currently, metal-stack organizes CIDRs / prefixes into a `network' resource in the metal-api. A network can consist of multiple CIDRs from the same address family. For example, if an operator wants to provide Internet connectivity to provisioned machines, they can start with small network CIDRs. The number of managed network prefixes can then be expanded as needed over time.

With dual-stack we have to choose between two options: Network per address family or networks with both address families. These options are described in the next section.

#### Network per Address Family

This means that we allow networks with CIDRs from one address family only, one for IPv4 and one for IPv6.

The machine creation process will not change if the machine only needs to be either IPv4 or IPv6 addressable.
But if on the other side, the machine need to be able to connect to both address families, the machine creation needs to specify two networks, one for IPv4 and one for IPv6.
Also there will be 2 distinct VRF IDs for every network with a different address family.

#### Network with both Address Families

Make a network dual address family capable, meaning that you can add multiple cidrs from both address families to a network.
Then the machine creation will remain the same for single-stack and dual-stack cases, but the ip address allocation will need to specify the address family from which to allocate an ip address when the network is dual-stack.
This does not break the existing API, but allows existing extensions to easily add dual-stack support.
To avoid additional checking of which address families are available on this network during an ip allocation call, we could store the address families in the network.

#### Decision

The decision was made to go with the having both address families in a single network entity because we think this is the most flexible way to support dual-stack machines and Kubernetes clusters as well as single-stack with the least amount of modifications on the networking side.

### Examples

To illustrate the the usage we start by creating a tenant super network which has both address families:

```yaml
---
id: tenant-super-network-mini-lab
name: Project Super Network
description: Super network of all project networks
partitionid: mini-lab
prefixes:
- 10.0.0.0/16
- 2001:db8:0:10::/64
defaultchildprefixlength:
  IPv4: 22
  IPv6: 96
privatesuper: true
...
```

In order to create this network, we simple call:

```bash
metalctl network create -f tenant-super.yaml
```

This is usually done during the initial setup of the environment.

Next step is to allocate a tenant network where the machines of a project can be placed:

```bash
metalctl network allocate --partition mini-lab --project 4b9b17c4-2d7c-4190-ae95-dda44e430fa6 --name my-node-network
```

This leads to the following network allocation:

```yaml
id: 2d2c0350-3f66-4597-ae97-ef6797232212
name: my-node-network
parentnetworkid: tenant-super-network-mini-lab
partitionid: mini-lab
prefixes:
- 10.0.0.0/22
- 2001:db8:0:10::/96
projectid: 4b9b17c4-2d7c-4190-ae95-dda44e430fa6
vrf: 20
consumption:
  ipv4:
    available_ips: 1024
    available_prefixes: 256
    used_ips: 2
    used_prefixes: 0
  ipv6:
    available_ips: 2147483647
    available_prefixes: 1073741824
    used_ips: 1
    used_prefixes: 0
privatesuper: false
```

Users can the create IP addresses from these child networks. By default, they retrieve an IPv4 address except a super network only consists of IPv6 prefixes. In the latter case the users acquire an IPv6 address.

```bash
metalctl network ip create --network 2d2c0350-3f66-4597-ae97-ef6797232212 --project 4b9b17c4-2d7c-4190-ae95-dda44e430fa6
```
