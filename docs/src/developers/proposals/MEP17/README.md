# BGP Data Plane Visibility

Currently, an operator cannot identify if an allocated IP is actually announced to the outer world.
At the edge of the network we would like to gather information about all routes announced from within the network.
This information should include a timestamp of the last announcement for each route.
If the timestamp is older than some threshold we will assume that the addresses are not longer used.

To achieve this we will extend the scope of metal-core so it can run on all types of switches, not only on leaves.
As a byproduct of this enhancement all switches will become visible via `metalctl switch ls`.
On the switches the metal-core will collect BGP routes and report them to the metal-apiserver.
The metal-apiserver will store these data to a separate table and query this table when an IP address is described.

## metal-core

### Switch Types

First of all, the metal-core should accept as an argument the type or role of the switch it is running on.
Possible types are:

- `leaf`
- `spine`
- `exit`
- `mgmtleaf`
- `mgmtspine`
- `mgmteor`

Depending on the type its reconciliation loop will differ.
The current behavior should mostly remain unchanged for leaf switches.
Things to change for non-leaves:

**Phoned Home**

Currently, a [go-lldp](https://github.com/metal-stack/go-lldpd) client is used to listen for LLDP messages from provisioned machines to report these as phoned-home events to the metal-api.
This mechanism is only needed on leaf switches.
On all other types of switch this entire procedure can be skipped.

**Port Configuration**

There are four kinds of ports for a leaf switch: spine uplink, unprovisioned port, firewall port, machine port.
Depending on the kind of port its configuration will differ in regards to MTU, VLAN binding and VRF binding.
Any non-leaf switches don't know anything about machines, firewalls and the provisioning cycle.
Their port configuration is static.

**FRR Config**

The same goes for the FRR config.
To dynamically adapt to machines being provisioned and unprovisioned, the metal-core periodically writes the `frr.conf` file.
This dynamic configuration is only necessary on the leaf switches.
All other switches need a static FRR config.

> In a future MEP we consider delegating the entire configuration of a switch to the metal-core.
> For now, all configuration that doesn't need to be dynamically adjusted will be deployed on the switch via metal-roles and the metal-core will mostly just report switch information to the metal-apiserver.

### BGP Announcements

Route information can be retrieved in JSON format from vtysh.
The metal-core should collect all routes it knows about and send them to the metal-apiserver along with a timestamp.

### Switch-to-Switch Connections

Similarly to the switch-to-machine connections where LLDP neighborship is used to learn about the physical connections, we can use LLDP to report connections between switches to the metal-apiserver.
For this, a separate LLDP client should be used, that forwards all LLDP messages, not only those of provisioned machines.

## metal-apiserver

A new GRPC endpoint should be exposed by the metal-apiserver to report BGP routes.

```proto
service IPService {
  rpc ReportBGPRoutes(IPServiceReportBGPRoutesRequest) returns (IPServiceReportBGPRoutesResponse) {
    option (project_roles) = PROJECT_ROLE_OWNER;
    option (project_roles) = PROJECT_ROLE_EDITOR;
    option (project_roles) = PROJECT_ROLE_VIEWER;
    option (auditing) = AUDITING_EXCLUDED;
  }
}

message IPServiceReportBGPRoutesRequest {
  repeated BGPRoute bgpRoutes = 1;
}

message BGPRoute {
  string cidr = 1;
  string switch_id = 2;
  google.protobuf.Timestamp last_announced = 3;
}
```

There should be a table for BGP routes in metal-db.
Whenever new routes are reported they get merged into the existing ones by the strategy:

- when new, just add
- when existing, update `last_announced` timestamp

An expiration threshold should be defined and all expired routes should be cleaned up periodically.

When an IP address is described with `metalctl network ip describe` the BGP routes should be queried.
If no route to the described IP was announced it should be indicated, e.g.

```bash
allocationuuid: allocation-id
description: my ip address
ipaddress: 100.0.0.1
name: ip-name
networkid: network-id
projectid: project-id
type: static
used: no # otherwise 'yes'
```
