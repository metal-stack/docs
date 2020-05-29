# Components

The metal-stack is a compound of microservices written in [Golang](https://golang.org/).

This page gives you an overview over which microservices exist, how they communicate with each other and where they are deployed.

```@contents
Pages = ["components.md"]
Depth = 5
```

## Metal Control Plane

The foundation of the metal-stack is what we call the _metal control plane_. The metal control plane is typically deployed in a Kubernetes cluster and is not strictly required to run inside your data center. It even makes sense not to place the metal control plane in the same failure domain with your servers that you are going to manage with the metal-stack. The control plane does not depend on Kubernetes functionality, such that deployments to other target platforms are theoretically possible.

The control plane contains of a couple of essential microservices for the metal-stack including:

- **[metal-api](https://github.com/metal-stack/metal-api)**
  The API to manage and control resources like machines, switches, operating system images, machine sizes, networks, IP addresses and more. The metal-api stores the state of these entities in a [RethinkDB](https://rethinkdb.com/) database. The metal-api also has it's own IP address management ([go-ipam](https://github.com/metal-stack/go-ipam)), which writes IP address and network allocations into a PostgreSQL backend.
- **[masterdata-api](https://github.com/metal-stack/masterdata-api)**
  Manages tenant and project entities, which can be described as entities used for company-specific resource separation and grouping. Having these "higher level entities" managed by a separate microservice was a design choice that allows to re-use the information by other microservices without having them to know the metal-api at all. The masterdata gets persisted in a dedicated PostgreSQL database.
- **[metal-console](https://github.com/metal-stack/metal-console)**
  Provides access for users to a machine's serial console via SSH. It can be seen as an optional component.
- **[nsq](https://nsq.io/)**
  A message queuing system (not developed by the metal-stack) used for decoupling microservices and distributing tasks.

The following figure shows the relationships between these microservices:

**TODO: add figure**

## Partitions

A _partition_ is our term for describing hardware in the data center (typically grouped in a rack or a group of racks) controlled by the metal-stack with all the hardware participating in the same network topology. For this reason, the hardware inside a partition belongs to the same failure domain. Even though the network topology for running the metal-stack is required to be redundant by design, you should consider setting up multiple partitions. With multiple partitions in your data center it is possible for users to maintain availability of their applications by spreading them across the partitions. Installing partitions in multiple data centers would be even better in regards of failsafe application performance, which would even tolerate the meltdown of a data center.

We strongly advise to group your hardware into racks that are specially made for running metal-stack. When you use modular rack design, extending the amount of compute resources of a partition can be done very easily by adding racks. This makes your infrastructure very elastic for end-users and allows them to scale their applications almost infinitely. How large you can grow your partitions and how the network topology inside a partition looks like is described in the [networks section](networking.md). The hardware that you can place inside a partition is described in the [hardware](hardware.md) document.

Inside a partition, the metal-stack requires a couple of servers serving special roles. These servers, which are not added to the pool of user-allocatable machines, we call  _management servers_. In addition to the management servers, the metal-stack has microservices running on the leaf switches. For this reason, your lead switches are required to run a Linux distribution that you have full access to.

The microservices running inside a partition are:

- **[metal-core](https://github.com/metal-stack/metal-core)**
- **[pixiecore](https://github.com/danderson/netboot/tree/master/pixiecore)**

**TODO: add figure**

## Entire Picture

**TODO: add figure**

By design, a partition only has very few ports open for incoming-connections from the internet. This contributes to a smaller attack surface and higher security of your infrastructure.
