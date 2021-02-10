# DMZ Networks

## Reasoning

To fulfill higher levels of security measures the standard metal-stack approach with a single firewall in front of a set of machines might be insufficient.
There are cases where two physically distinct firewalls in front of application workload are mandatory. In traditional network terms this is known as DMZ approach.

For Kubernetes workloads it makes sense to use the front cluster for ingress, WAF purposes and as outgoing proxy. The clusters may be used for application workload.

## Approach

![DMZ Internet](dmz-internet.png)

### DMZ network

- Use a separate DMZ network prefix for every tenant
- This is used as intermediate network btw. private networks of a tenant and the internet
- For every partition a distinct DMZ firewall/cluster is needed for a tenant
- For Gardener orchestrated Kubernetes clusters this network must be a publicly reachable internet prefix because shoot clusters need a vpn service that is used for instrumentation from the seed cluster - this will be a requirement as long as the inverse vpn tunnel feature Konnectivity is not available to us.

Such a network will look like this in the metal-api:

```yaml
---
description: DMZ-Network
destinationprefixes:
- 0.0.0.0/0
id: dmz
labels:
  network.metal-stack.io/default-external: ""
name: DMZ-Network
nat: true
parentnetworkid: null
partitionid: ""
prefixes:
- 10.90.30.128/25
privatesuper: false
projectid: ""
underlay: false
vrf: 104007
vrfshared: false
```

### DMZ firewall

The firewall of the DMZ will intersect its private network for attached machines, the DMZ network and the public internet.

- The private network of the project needs to import
   - the default route from the internet network
   - the DMZ network
- The internet network must import the DMZ network locally (no-export)
- The DMZ network provides the default route for a tenant's clusters in a partition. It imports the default route from the internet network

**Topics that need to be addressed with code changes:**
- metal-networker and metal-ccm assume that there is only one network providing the default-route
- we need a marker so that metal-networker knows to import the default route from the real internet network to the dmz network
- we need a marker so that metal-networker knows to import the dmz network to the internet network (is only needed for publicly available dmz ips)

### Application Firewall

The firewall of application workloads intersects its private network for attached machines and the DMZ network.

This is currently supported by the metal-networker and needs no further changes!
