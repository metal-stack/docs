# Comparison with commercial Solutions

As metal-stack is the foundation to build kubernetes clusters on premise on bare metal, there are several commercial solutions available which offer management of kubernetes.
In this document we describe the difference of some of the most popular solutions. It´s is not a complete list.

```@contents
Pages = ["comparison.md"]
Depth = 5
```

In this document we want to compare a often cited battle between Kubernetes managed by Gardener on Metal Stack and Openshift running on VMWare.

## Gardener

[Gardener](https://gardener.cloud) is a Kubernetes Cluster manager to organize a fleet of Kubernetes Clusters at Scale. It is designed to scale to thousands of clusters at a variety of IaaS Providers regardles where, in the Cloud or On Premise, virtualized or bare metal.
It manages not only the creation and deletion of a Kubernetes Cluster, it also takes care of updates and upgrades of kubernetes and the Operating System of the involved Worker Nodes in a automatic Manner. Its designed Cloud Native as it defines Clustes, Workers and all other Components like Pods and Deployments as Kubernetes Resources which are reconciled to the desired state.

## Kubernetes

[Kubernetes](https://kubernetes.io) is the de facto Open Source standard for Container Scheduling and Orchestration in the Datacenter.

## Openshift

A Fork of Kubernetes with proprietary addons, created by RedHat. For all Details see: [https://en.wikipedia.org/wiki/OpenShift](https://en.wikipedia.org/wiki/OpenShift).

## Metal Stack

Is a [IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service) provider for bare metal focused to create Kubernetes Cluster On Premise. Gardener support is built in.

## VMWare

The most used virtualization technology in the Enterprise Datacenters.

| Feature                                  | Gardener on Metal Stack                                                           | Openshift on VMWare                                         |
|------------------------------------------|-----------------------------------------------------------------------------------|-------------------------------------------------------------|
| Container Runtime                        | docker, containerd, gvisor                                                        | cri-o                                                       |
| Host Operating System                    | Ubuntu, Debian                                                                    | RHEL, Fedora-Core                                           |
| Network Plugins                          | Calico, Cilium                                                                    | Openshift SDN                                               |
| Storage                                  | Local NVME, Lightbits NVMEoTCP, all CSI compatible Solutions                      | CSI compatible                                              |
| Loadbalancing                            | BGP built in                                                                      | requires extra HW like F5                                   |
| IO at Native Speed                       | Pods run on bare metal                                                            | all IO must go through the Hypervisor                       |
| Hard Multitenancy                        | Workers, Firewall and Loadbalancers are dedicated for every cluster on bare metal | Shared virtualization hosts, shared Loadbalancers           |
| UI                                       | Gardener Dashboard                                                                | Openshift Console                                           |
| Manages Kubernetes Installation at scale | Yes                                                                               | Requires extra licences SW: Redhat Advanced Cluster Manager |
| Automatic Kubernetes Updates             | Yes                                                                               | Yes                                                         |
| Automatic Worker Nodes Updates           | Yes                                                                               | Yes                                                         |
| Supported IaaS Providers                 | GCP, AWS, Azure, Alibaba, Openstack, VMWare, Metal Stack and more                 | GCP, AWS, Azure Openstack, VMWare                           |
| Monitoring / Logging Stack               | Grafana/Loki, Kibana/Elastic                                                      | Kibana/Elastic                                              |
| GitOPS                                   | Tool of choice via Helm Install                                                   | Openshift GitOPS                                            |
| Container Registry                       | all public accessible registries, private deployed registry of choice             | all public accessible registries, in cluster registry       |
| CI/CD                                    | Tool of choice via Helm Install                                                   | Jenkins                                                     |
| Security                                 | PSP enabled by default                                                            | Strong cluster defaults                                     |
| CNCF Kubernetes certified                | Yes                                                                               | Yes                                                         |
| Local development                        | minikube, kind                                                                    | minishift                                                   |
| Proprietary extensions                   | No                                                                                | DeploymentConfig and others                                 |
| kubectl access                           | Yes                                                                               | Yes                                                         |
| helm support | Yes                           | Yes                                                             |

