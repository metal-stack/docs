# Why metal-stack?

Before we started with our mission to implement the metal-stack, we decided on a couple of key characteristics and constraints that we think are unique in the domain (otherwise we would definitely have chosen an existing solution).

We hope that the following properties appeal to you as well.

## On-Premise

Running on-premise gives you data sovereignty and usually a better price / performance ratio than with hyperscalers — especially the larger you grow your environment. Another benefit of running on-premise is an easier connectivity to existing company networks.

## Fast Provisioning

Provisioning bare metal machines should not feel much different from virtual machines. metal-stack is capable of provisioning servers in less than a minute. The underlying network topology is based on BGP and allows announcing new routes to your host machines in a matter of seconds.

## No-Ops

Part of the metal-stack runs on dedicated switches in your data center. This way, it is possible to automate server inventorization, permanently reconcile network configuration and automatically manage machine lifecycles. Manual configuration is neither required nor wanted.

## Security

Our networking approach was designed for highest standards on security. Also, we enforce firewalling on dedicated tenant firewalls before users can establish connections to other networks than their private tenant network. API authentication and authorization is done with the help of OIDC.

## API driven

The development of metal-stack is strictly API driven and offers self-service to end-users. This approach delivers the highest possible degree of automation, maintainability and performance.

## Ready for Kubernetes

Not only does the metal-stack run smoothly on [Kubernetes](https://kubernetes.io/) (K8s). The major intent of metal-stack has always been to build a scalable machine infrastructure for _Kubernetes as a Service (KaaS)_. In partnership with the open-source project [Gardener](https://gardener.cloud/), we can provision Kubernetes clusters on metal-stack at scale.

From the perspective of the Gardener, the metal-stack is just another cloud provider. The time savings compared to providing machines and Kubernetes by hand are significant. We actually want to be able to compete with offers of public cloud providers, especially regarding speed and usability.

Of course, you can use metal-stack only for machine provisioning as well and just put something else on top of your metal infrastructure.

## Comparison with Commercial Solutions

As metal-stack is the foundation to build Kubernetes clusters on premise on bare metal, there are several commercial solutions available which offer management of Kubernetes.
In this document we describe the differences between some of the most popular solutions. It´s is not a complete list.

Comparison between Gardener on Metal Stack and Openshift running on VMWare.

### Gardener

[Gardener](https://gardener.cloud) is a Kubernetes cluster manager to organize a fleet of Kubernetes clusters at scale. It is designed to scale to thousands of clusters at a variety of IaaS Providers regardless where - in the cloud or on premise, virtualized or bare metal.
It not only manages the creation and deletion of Kubernetes clusters, it also takes care of updating or upgrading Kubernetes and the operating system of the involved worker nodes in a automatic manner. Gardener is designed cloud-native and as such, it defines clusters, workers and all other components as Kubernetes resources (like pods and deployments) and reconciles these resources to the desired state.

### Kubernetes

[Kubernetes](https://kubernetes.io) is the de facto open-source standard for container scheduling and orchestration in the data center.

### Openshift

A fork of Kubernetes with proprietary addons, created by RedHat. For all details see: [https://en.wikipedia.org/wiki/OpenShift](https://en.wikipedia.org/wiki/OpenShift).

### metal-stack

Is an [IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service) provider for bare metal focused to create Kubernetes cluster on premise. Gardener support is built in.

### VMWare

The most used virtualization technology in the enterprise data centers.

### Comparison of Gardener on Metal Stack vs. Openshift on VMWare

| Feature                        | Gardener on Metal Stack                                                                                       | Openshift on VMWare                                         |
| :----------------------------- | :------------------------------------------------------------------------------------------------------------ | :---------------------------------------------------------- |
| Container Runtime              | docker, containerd, gvisor                                                                                    | cri-o                                                       |
| Host Operating System          | Ubuntu, Debian , also see [OS](../operators/operating-systems.md)                                             | RHEL, Fedora-Core                                           |
| Network Plugins                | Calico, Cilium(soon)                                                                                          | Openshift SDN                                               |
| Storage                        | Local NVME, Lightbits NVMEoTCP, all CSI compatible Solutions, also see [Storage](./kubernetes/storage.md)     | CSI compatible                                              |
| Loadbalancing                  | BGP built in                                                                                                  | requires extra HW like F5, VMWare NSX                       |
| IO at Native Speed             | Pods run on bare metal                                                                                        | all IO must go through the Hypervisor                       |
| Hard Multitenancy              | Workers, firewall and load balancers are dedicated for every cluster on bare metal                            | Shared virtualization hosts, shared load balancers          |
| UI                             | Gardener Dashboard                                                                                            | Openshift Console                                           |
| Multi-cluster management       | Yes (through Gardener)                                                                                        | Requires extra licences SW: Redhat Advanced Cluster Manager |
| Automatic Kubernetes Updates   | Yes                                                                                                           | Yes                                                         |
| Automatic Worker Nodes Updates | Yes                                                                                                           | Yes                                                         |
| Supported IaaS Providers       | GCP, AWS, Azure, Alibaba, Openstack, VMWare, metal-stack and more                                             | GCP, AWS, Azure Openstack, VMWare                           |
| Monitoring / Logging Stack     | Grafana/Loki, Kibana/Elastic                                                                                  | Kibana/Elastic                                              |
| GitOPS                         | Tool of choice via Helm Install                                                                               | Openshift GitOPS                                            |
| Container Registry             | all public accessible registries, private deployed registry of choice                                         | all public accessible registries, in cluster registry       |
| CI/CD                          | Tool of choice via Helm Install                                                                               | Jenkins                                                     |
| Security                       | K8s control plane isolated from tenant, PSP enabled by default                                                | Strong cluster defaults                                     |
| CNCF Kubernetes certified      | Yes (Gardener)                                                                                                | Yes                                                         |
| Local development              | [minikube](https://minikube.sigs.k8s.io/docs/start/), [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) | [minishift](https://github.com/minishift/minishift)         |
| Proprietary extensions         | No                                                                                                            | DeploymentConfig and others                                 |
| kubectl access                 | Yes                                                                                                           | Yes                                                         |
