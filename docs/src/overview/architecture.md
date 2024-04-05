# Architecture

The metal-stack is a compound of microservices predominantly written in [Golang](https://go.dev/).

This page gives you an overview over which microservices exist, how they communicate with each other and where they are deployed.

```@contents
Pages = ["architecture.md"]
Depth = 5
```

## Target Deployment Platforms

For our environments, we chose to deploy the metal-stack into a Kubernetes cluster. This means that also our entire installation was developed for metal-stack being run on Kubernetes. Running applications on Kubernetes gives you a lot of benefits regarding ease-of-deployment, scalability, reliability and so on.

However, very early we decided that we do not want to depend on technical Kubernetes functionality with our software (i.e. we did not implement the stack "kube-native" by using controllers and Kubernetes CRDs and things like that). With the following paragraph we want to point out the reasoning behind this "philosophical" decision that may sound conservative at first glance. But not relying on Kubernetes technology:

- Makes deployments of the stack without Kubernetes theoretically possible.
  - We believe that cloud providers should be able to act beneath Kubernetes
  - This way it is possible to use metal-stack for providing your own Kubernetes offering without relying on Kubernetes yourself (breaks the chicken-egg problem)
- Follows an important claim in microservice development: "Be agnostic to your choice of technology"
  - For applications that are purely made for being run on Kubernetes, it does not matter to rely on this technology (we even do the same a lot with our applications that integrate the metal-stack with Gardener) but as soon as you start using things like the underlying reconciliation abilities (which admittedly are fanstatic) you are locking your code into a certain technology
  - We don't know what comes after Kubernetes but we believe that a cloud offering should have the potential to survive a choice of technology
  - By this decision we ensured that we can migrate the stack to another future technology and survive the change

One more word towards determining the location for your metal control plane: It is not strictly required to run the control plane inside the same data center as your servers. It even makes sense not to do so because this way you can place your control plane and your servers into a different failure domains, which makes your installation more robust to data center meltdown. Externally hosting the control plane brings you up and running quickly plus having the advantage of higher security through geo-distribution.

## Metal Control Plane

The foundation of the metal-stack is what we call the _metal control plane_.

The control plane contains of a couple of essential microservices for the metal-stack including:

- **[metal-api](https://github.com/metal-stack/metal-api)**
  The API to manage and control plane resources like machines, switches, operating system images, machine sizes, networks, IP addresses and more. The exposed API is an old-fashioned REST API with different authentication methods. The metal-api stores the state of these entities in a [RethinkDB](https://rethinkdb.com/) database. The metal-api also has its own IP address management ([go-ipam](https://github.com/metal-stack/go-ipam)), which writes IP address and network allocations into a PostgreSQL backend.
- **[masterdata-api](https://github.com/metal-stack/masterdata-api)**
  Manages tenant and project entities, which can be described as entities used for company-specific resource separation and grouping. Having these "higher level entities" managed by a separate microservice was a design choice that allows to re-use the information by other microservices without having them to know the metal-api at all. The masterdata gets persisted in a dedicated PostgreSQL database.
- **[metal-console](https://github.com/metal-stack/metal-console)**
  Provides access for users to a machine's serial console via SSH. It can be seen as an optional component.
- **[nsq](https://nsq.io/)**
  A message queuing system (not developed by the metal-stack) used for decoupling microservices and distributing tasks.

The following figure shows the relationships between these microservices:

![Metal Control Plane](metal-stack-control-plane.drawio.svg)

> Figure 1: The metal control plane deployed in a Kubernetes environment with an ingress-controller exposing additional services via [service exposal](https://kubernetes.github.io/ingress-nginx/user-guide/exposing-tcp-udp-services/).

Some notes on this picture:

- Users can access the metal-api with the CLI client called [metalctl](https://github.com/metal-stack/metalctl).
- You can programmatically access the metal-api with [client libraries](../development/client_libraries.md) (e.g. [metal-go](https://github.com/metal-stack/metal-go)).
- Our databases are wrapped in a specially built [backup-restore-sidecar](https://github.com/metal-stack/backup-restore-sidecar), which is consistently backing up the databases in external blob storage.
- The metal-api can be scaled out using replicas when being deployed in Kubernetes.

## Partitions

A _partition_ is our term for describing hardware in the data center controlled by the metal-stack with all the hardware participating in the same network topology. Being in the same network topology causes the hardware inside a partition to build a failure domain. Even though the network topology for running the metal-stack is required to be redundant by design, you should consider setting up multiple partitions. With multiple partitions it is possible for users to maintain availability of their applications by spreading them across the partitions. Installing partitions in multiple data centers would be even better in regards of fail-safe application performance, which would even tolerate the meltdown of a data center.

!!! tip

    In our setups, we encode the name of a region and a zone name into our partition names. However, we do not have dedicated entities for regions and zones in our APIs.

    A **region** is a geographic area in which data centers are located.

    **Zones** are geographic locations in a region usually in different fire compartments. Regions can consist of several zones.

    A zone can consist of several **partitions**. Usually, a partition spans a rack or a group of racks.

We strongly advise to group your hardware into racks that are specifically assembled for running metal-stack. When using modular rack design, the amount of compute resources of a partition can easily be extended by adding more racks to your partition.

!!! info

    The hardware that we currently support to be placed inside a partition is described in the [hardware](hardware.md) document.

!!! info

    How large you can grow your partitions and how the network topology inside a partition looks like is described in the [networking](networking.md) document.

The metal-stack has microservices running on the leaf switches in a partition. For this reason, your leaf switches are required to run a Linux distribution that you have full access to. Additionally, there are a servers not added to the pool of user-allocatable machines, which are instead required for running metal-stack and we call them _management servers_. We also call the entirety of switches inside a partition the _switch plane_.

The microservices running inside a partition are:

- **[metal-hammer](https://github.com/metal-stack/metal-hammer)** (runs on a server when not allocated by user, often referred to as _discovery image_) An initrd, which is booted up in PXE mode, preparing and registering a machine. When a user allocates a machine, the metal-hammer will install the target operating system on this machine and kexec into the new operating system kernel.
- **[metal-core](https://github.com/metal-stack/metal-core)** (runs on leaf switches) Dynamically configures the leaf switch from information provided by the metal-api. It also proxies requests from the metal-hammer to the metal-api including publishment of machine lifecycle events and machine registration requests.
- **[pixiecore](https://github.com/danderson/netboot/tree/master/pixiecore)** (preferably runs on management servers, forked by metal-stack) Provides the capability of PXE booting servers in the PXE boot network.
- **[metal-bmc](https://github.com/metal-stack/metal-bmc)** (runs on management servers) Reports the ip addresses that are leased to ipmi devices together with their machine uuids to the metal-api. This provides machine discovery in the partition machines and keeps all IPMI interface access data up-to-date. Also forwards metal-console requests to the actual machine, allowing user access to the machine's serial console. Furthermore it processes firmware updates and power on/off, led on/off, boot order changes.

![Partition](metal-stack-partition.drawio.svg)

> Figure 2: Simplified illustration of services running inside a partition.

Some notes on this picture:

- This figure is slightly simplified. The switch plane consists of spine switches, exit routers, management firewalls and a bastion router with more software components deployed on these entities. Please refer to the [networking](networking.md) document to see the full overview over the switch plane.
- The image-cache is an optional component consisting of multiple services to allow caching images from the public image store inside a partition. This brings increased download performance on machine allocation and increases independence of a partition on the internet connection.

## Complete View

The following figure shows several partitions connected to a single metal control plane. Of course, it is also possible to have multiple metal control planes, which can be useful for staging.

![metal-stack](metal-stack-architecture.drawio.svg)

> Figure 3: Reduced view on the communication between the metal control plane and multiple partitions.

Some notes on this picture:

- By design, a partition only has very few ports open for incoming-connections from the internet. This contributes to a smaller attack surface and higher security of your infrastructure.
- With the help of NSQ, it is not required to have connections from the metal control plane to the metal-core. The metal-core instances register at the message bus and can then consume partition-specfic topics, e.g. when a machine deletion gets issued by a user.

## Machine Provisioning Sequence

The following sequence diagram illustrates some of the main principles of the machine provisioning lifecycle.

![provisioning sequence](provisioning_sequence.drawio.svg)

> Figure 4: Sequence diagram of the machine provisioning sequence.

Here is a video showing a screen capture of a machine's serial console while running the metal-hammer in "wait mode". Then, a user allocates the machine and the metal-hammer installs the target operating system and the machine boots into the new operating system kernel via the kexec system call.

```@raw html
<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/3oEhInk6BaU" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>
```
