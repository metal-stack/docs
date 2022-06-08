# No Open Ports To the Data Center

Our metal-stack partitions typically have open ports for metal-stack native services, these are:

- SSH port on the firewalls
- bmc-reverse-proxy for serial console access through the metal-console

Primarily the reason to get rid off these open ports is the reduction of the attack surface to the data center.

As a next step, we can also cosider joining the management servers to the VPN mesh, which would replace typical Wireguard setups for operators to enter resources inside the partition.

[](./architecture.drawio.svg)

> Simplified drawing showing old vs. new architecture.

## Firewalls

### Implementation

- Add a headscale server to the metal control plane
- The firewall allocation process in the metal-api will change the following way
  1. Request a one-time joining token for the firewall VPN from the headscale gRPC endpoint (1 hour expiration time)
  1. Inject the tailscaled service configuration into the userdata and launch it through ignition (along with user-given userdata)
- Connection to headscale server is an optional configuration for the metal-api, without this configuration the whole firewall allocation process will remain the same as of today
- Operators can join the VPN mesh
  - Issue a command like `metalctl firewall vpn-join-token`

## bmc-reverse-proxy

TODO
