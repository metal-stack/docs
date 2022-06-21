# No Open Ports To the Data Center

Our metal-stack partitions typically have open ports for metal-stack native services, these are:

- SSH port on the firewalls
- bmc-reverse-proxy for serial console access through the metal-console

These open ports are potential security risks. For example, while SSH access is possible only with private key it's still vulnerable to DoS attack.

Therefore, we want to get rid off these open ports to reduce the attack surface to the data center.

## Requirements

- Access to firewall SSH only via VPN
- Easy to update VPN components

As a next step, we can also consider joining the management servers to the VPN mesh, which would replace typical WireGuard setups for operators to enter resources inside the partition.

## High Level Design

[](./architecture.drawio.svg)

> Simplified drawing showing old vs. new architecture.

Store current Headscale and desired Tailscale(`metalctl`?) version in some K8s resource? And allow to update it via `metalctl`.

### Concerns

There's few concerns when using WireGuard for implementing VPN:

1. WireGuard doesn't implement dynamic cipher substitution. Which is important in case one of the crypto methods, used by WireGuard will be broken. The only possible solution for that will be to update WireGuard to a fixed version.
2. Coordination server(Headscale) is a single point of failure. In case it fails, it potentially can disconnect existing members of the network, as WireGuard can't manage dynamic IPs by itself.
3. Headscale is already falls behind Tailscale coordination server implementation. Which can complicate the upgrade to newer version of Tailscale client in case of emergency.

### Solutions to concerns

1. Tailscale node software is using userspace implementation of WireGuard -- `wireguard-go`. One of the options is to inject Tailscale client into `metalctl`. And make it available as `metalctl vpn` or similar command. It should be possible to do as `tailscale` node is already available as open sourced Go pkg. That would allow us to control, what version of Tailscale users are using and in case of any critical changes to enforce them to update `metalctl` to use VPN functionality.
2. Would it be a considerable risk? We could look into `wg-dynamic` project to cover this problem.

## Implementation Details

`headscale` should be deployed/updated via `metal-roles`. Also, it should be possible to manage desired `tailscale` version through roles.

### New `metalctl` commands

- `metalctl vpn` -- section for VPN related commands:
    - `metalctl vpn get key [vpn name] --namespace [namespace name]` -- returns auth key to be used with `tailscale` client for establishing connection.

Extend `metalctl firewall`:
- `metalctl firewall ssh [ID]` -- connect to firewall via SSH.

Extend `metalctl machine`:
- `metalctl machine ssh [ID]` -- connect to machine via SSH.

`metalctl` should be able to connect to firewall and machines by running `tailscale` in container.

### Resources
Update `Firewall` resource to include desired/actual `tailscale` version:

```
Firewall:
  Spec:
    tailscale:
      Version:   Minimal version
    ...
  Status:
    ...
    VPN:
      Status:    Boolean field
    tailscale:
      Version:   Actual version
    ...
```

### metal-api
Add new endpoints:
- `/v1/vpn/allocate POST` -- should deploy `headscale` server.
- `/v1/vpn/update PUT`
- `/v1/vpn/namespace/allocate POST` 
- `/v1/vpn GET` -- requests auth key from `headscale` server.

Update schema `FirewallCreateRequest` with additional properties `vpn`, `namespace`. Same with `MachineAllocateRequest` request.

Also, need to update schema in `metal-db`(is it correct DB or should some other be used?).

### metal-networker
`metal-networker` also have to know if VPN was configured. In that case we need to disable public access to SSH and allow all(?) traffic from WireGuard interface.

### firewall-controller
`firewall-controller` have to monitor changes in `Firewall` resource and keep `tailscale` version up-to-date.

### bmc-reverse-proxy

TODO

## References

1. [WireGuard: Next Generation Secure Network Tunnel](https://www.youtube.com/watch?v=88GyLoZbDNw)
2. [How Tailscale works](https://tailscale.com/blog/how-tailscale-works/)
3. [Tailscale is officially SOC 2 compliant](https://tailscale.com/blog/soc2/)
4. [Why not Wireguard](https://blog.ipfire.org/post/why-not-wireguard)
5. [Wireguard: Known Limitations](https://www.wireguard.com/known-limitations/)
6. [Wireguard: Things That Might Be Accomplished](https://www.wireguard.com/todo/)
7. [Headscale: Tailscale control protocol v2](https://github.com/juanfont/headscale/issues/526)
