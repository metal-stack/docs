# Components

The metal-stack is a compound of microservices written in [Golang](https://golang.org/).

This page gives you an overview over which microservices exist, how they communicate with each other and where they are deployed.

```@contents
Pages = ["components.md"]
Depth = 5
```

## Metal Control Plane

The foundation of the metal-stack is what we call the _metal control plane_. The metal control plane is typically deployed in a Kubernetes cluster and is not strictly required to run inside your data center. It even makes sense not to place the metal control plane in the same failure domain as the server racks that you are going to manage with it. The control plane does not have any requirements on Kubernetes functionality by itself, such that deployments on other target platforms are theoretically possible.

The control plane contains of a couple of essential microservices including:

- **[metal-api](https://github.com/metal-stack/metal-api)** The API to manage and control resources like machines, switches, operating system images, machine sizes, networks, IP addresses and more. The metal-api stores the state of these entities in a [RethinkDB](https://rethinkdb.com/) database. The metal-api also has it's own IP address management ([go-ipam](https://github.com/metal-stack/go-ipam)), which writes IP address and network allocations into a PostgreSQL backend.
- **[masterdata-api](https://github.com/metal-stack/masterdata-api)** Manages tenant and project entities, which can be described as entities used for company-specific resource separation and grouping. Having these "higher level entities" managed by a separate microservice allows re-using the information by other microservices without having to know the metal-api at all. The masterdata gets persisted in a dedicated PostgreSQL database.
- **[metal-console](https://github.com/metal-stack/metal-console)** Provides access for users to a machine's serial console via SSH.
- **[nsq](https://nsq.io/)** A message queuing system (not developed by the metal-stack) used for decoupling microservices and distributing tasks.

This figure shows the relationships between these microservices:

**TODO: add figure**

## Partitions



## Entire Picture
