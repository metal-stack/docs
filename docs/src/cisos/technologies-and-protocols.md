# Technologies and Protocols

This section provides an overview of the key technologies and protocols used within metal-stack. It aims to give users and operators a better understanding of how the system is composed, how it communicates internally, and what standards it relies on.


If metal-stack control plane components run within a Kubernetes cluster, each component operates inside its own pod. These pods communicate over Layer 3 (IP-based) networking, using standard TCP/IP protocols. The underlying connectivity is provided by the Container Network Interface (CNI), which sets up a virtual network layer that enables seamless communication between pods across the cluster.

For network-based bootstrapping, **PXE (Preboot eXecution Environment)** is used, relying on **DHCP** for IP configuration and **TFTP** for transferring boot files over **UDP**. **iPXE** extends PXE capabilities by supporting **HTTP** for OS image loading, which uses the **TCP** protocol for faster and more reliable transfers.

In the networking layer, **VLANs** provide Layer 2 traffic segmentation. **VXLAN** encapsulates Layer 2 frames over Layer 3 IP networks using **UDP**, enabling scalable overlay networking. **VRF** allows the creation of isolated routing tables for traffic separation. **IP** and **ICMP** support basic connectivity and diagnostics.

For neighbor discovery and metadata exchange at Layer 2, **LLDP** is used.

Routing and modern overlay networking are established through **BGP** in combination with **EVPN**, enabling dynamic route distribution and MAC address advertisement over VXLAN-based fabrics.
