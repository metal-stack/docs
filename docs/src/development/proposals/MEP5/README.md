# Shared Networks

## Why are shared networks needed

For special purpose machines that serve shared services to all machines of a partition (like persistent storage) it would be good to have kind of a "shared network" that is easily accessible.
They do not necessarily need another firewall. This would avoid having two firewalls in the datapath between a machine in a private network and the machines of a shared service.

## Constraints that need to hold

- a shared network is usable from all machines that have a firewall in front, that uses it
- a shared network is only usable within a single partition
- neither machines nor firewalls may have multiple private, unshared networks configured
- machines must have a single primary network configured
    - this might be a shared network
    - OR a plain, old, unshared private network
- firewalls may participate in multiple shared networks
- primary network must not be specified with noauto

## Should shared networks be private

If we implemented shared networks by extending functions around plain, old, private networks we would not have to manage another CIDR (mini point).

If shared networks are implemented as first class networks we could customize the VRF and also accomplish an other goal of our roadmap: being able to create machines directly in an external network.

## Firewalls accessing a shared network

Firewalls that access shared networks need to:

- hide the private network behind an ip address of the shared network, otherwise we would need to know the changing list of private networks in the shared network's VRF for having a route back.
- import the prefixes of the shared VRF to the private VRF with the BGP attribute `no-export` so that flows to the shared network find their way out of the private VRF (but those prefixes are only of interest locally, they don't need to be propagated with BGP: `no-export` attribute)
- import the prefixes of the private VRF to the shared VRF so that flows originating in the private VRF that were SNATted find their way back (but those prefixes are only of interest locally, they don't need to be propagated with BGP: `no-export` attribute)

[Shared Networks](./shared.png)

## Getting internet acccess

Machines contained in a shared network can access the internet with different scenarios:

- if they have an own firewall: this is internet accessibility, as common
- if they don't have an own firewall, an external HTTP proxy is needed that has an endpoint in the shared network (metal-ccm needs to allow services in shared networks)
- if the shared network is "the internet", internet access is trivial because machines have a public address at their loopback interface
