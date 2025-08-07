# Global Network View

> [!IMPORTANT]  
> This MEP assumes the implementation of the metal-apiserver as described by [MEP-4](../MEP4/README.md) which is currently work in progress.

Having a complete view of the network topology is useful when working with deployments or troubleshooting connectivity issues.
Currently, the API doesn't know of any other switches than the leaf switches.
Information about all other switches and their connections must be gathered from Ansible inventories or by accessing the switches via SSH.
Documentation of each partition's network must be kept in-sync with all changes made to the deployment or cabling.
We would like to expand the API's knowledge of the network to the entire underlay including inter-switch connections as well as BGP statistics and health status.

## Switch Types

Registering a switch at the API is done by the metal-core.
Apart from that, it also reconciles port and FRR configuration to adapt to the machine provisioning cycle.
This reconfiguration is only necessary on the leaf switches.
To allow deploying the metal-core on other switches than leaves we need a way of telling it what type of switch it is running on so it can act accordingly.
On any non-leaf switches it will only register the switch and report statistic but not change any configuration.
Supported switch types are

- `leaf`
- `spine`
- `exit`
- `mgmtleaf`
- `mgmtspine`

## Network Topology

All switches should periodically report their LLDP neighbors and port configuration.
This information can be used to quickly identify common network issues, like MTU mismatch or the like.
Ideally, there would be some graphical representation of the network topology containing only the most important information for a quick overview.
It should contain all switches and machines as nodes and all connections as edges of a graph.
Ports, VRFs, and maybe also IPs should be associated with a connection.

Apart from the topology graph, there should be a way to display more detailed information about both ports of a connection, like

- MTU
- speed
- IP
- UP/DOWN status
- VRF
- VLAN
- whether it participates in a BGP session

## BGP Announcements

The metal-core should collect all routes it knows about and send them to the API along with a timestamp.
Reported routes should be stored to a redis database along with the switch that reported them and the timestamp of the last time they were reported.
An expiration threshold should be defined and all expired routes should be cleaned up periodically.
Whenever new routes are reported they get merged into the existing ones by the strategy:

- when new, just add
- when existing, update `last_announced` timestamp

By querying the BGP announcements we can find out whether an allocated IP is still in use.
