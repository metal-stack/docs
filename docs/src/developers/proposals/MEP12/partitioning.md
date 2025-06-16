---
marp: true
theme: metal-stack
paginate: true
footer: Gerrit Schwerthelm – x-cellent technologies GmbH — metal-stack Training
backgroundImage: url("https://metal-stack.io/images/shape/banner.png")
---
<!-- _class: cover lead -->

![h:200px](https://metal-stack.io/images/metal-stack-full-white-border.svg)

---
<!-- _class: cover lead -->

# Multi-Partition-Layout

---
<!--
_class: lead
_backgroundColor: #1f1f1f
_backgroundImage:
_footer: ""
-->
![bg contain](partitioning-1.svg)

---
<!--
_class: lead
_backgroundColor: #1f1f1f
_backgroundImage:
_footer: ""
-->
![bg contain](partitioning-2.svg)

---
<style>section { font-size: 30px; }</style>

# Multi-Partition-Layout Properties


- Fully independent locations with own storage and own node networks
- Clusters can only be created independent in every location
  - Failover mechanism for deployed applications requires duplicated deployments, which can serve independently
  - Failover through BGP
- If cluster nodes are spread across partitions (not implemented yet), nodes will not be able to reach each other
  - Would require an overlay network for inter-node-communication

---
<!-- _class: cover lead -->

# Single-Partition-Layout

---
<!--
_class: lead
_backgroundColor: #1f1f1f
_backgroundImage:
_footer: ""
-->
![bg contain](partitioning-3.svg)

---
<style>section { font-size: 30px; }</style>

# Single-Partition-Layout Properties

- Multiple groups of racks at multiple locations but connected to same CLOS topology
- All racks can connect to the same storage network
- Nodes in private networks can communicate
- When creating a cluster, nodes will be randomly spread across the racks
  - Possible improvement of this situation, see `MEP-12: Rack Spreading`

---

# MEP-12: Rack Spreading

- Instead of selecting a machine from a machine pool randomly
- Get all existing machines in the same project and count to which rack they belong
- Place machine on the rack with the least amount of machines already allocated
- Best effort only
