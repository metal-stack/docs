# Comparison with Commercial Solutions

As metal-stack is the foundation to build Kubernetes clusters on premise on bare metal, there are several commercial solutions available which offer management of Kubernetes.
In this document we describe the differences between some of the most popular solutions. It´s is not a complete list.

```@contents
Pages = ["comparison.md"]
Depth = 5
```

Comparison between Gardener on Metal Stack and Openshift running on VMWare.

## Gardener

[Gardener](https://gardener.cloud) is a Kubernetes cluster manager to organize a fleet of Kubernetes clusters at scale. It is designed to scale to thousands of clusters at a variety of IaaS Providers regardless where - in the cloud or on premise, virtualized or bare metal.
It not only manages the creation and deletion of Kubernetes clusters, it also takes care of updating or upgrading Kubernetes and the operating system of the involved worker nodes in a automatic manner. Gardener is designed cloud-native and as such, it defines clusters, workers and all other components as Kubernetes resources (like pods and deployments) and reconciles these resources to the desired state.

## Kubernetes

[Kubernetes](https://kubernetes.io) is the de facto open-source standard for container scheduling and orchestration in the data center.

## Openshift

A fork of Kubernetes with proprietary addons, created by RedHat. For all details see: [https://en.wikipedia.org/wiki/OpenShift](https://en.wikipedia.org/wiki/OpenShift).

## metal-stack

Is an [IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service) provider for bare metal focused to create Kubernetes cluster on premise. Gardener support is built in.

## VMWare

The most used virtualization technology in the enterprise data centers.

## Comparison of Gardener on Metal Stack vs. Openshift on VMWare

| Feature                        | Gardener on Metal Stack                                                                                       | Openshift on VMWare                                         |
|:-------------------------------|:--------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------|
| Container Runtime              | docker, containerd, gvisor                                                                                    | cri-o                                                       |
| Host Operating System          | Ubuntu, Debian                                                                                                | RHEL, Fedora-Core                                           |
| Network Plugins                | Calico, Cilium                                                                                                | Openshift SDN                                               |
| Storage                        | Local NVME, Lightbits NVMEoTCP, all CSI compatible Solutions                                                  | CSI compatible                                              |
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
| Security                       | PSP enabled by default                                                                                        | Strong cluster defaults                                     |
| CNCF Kubernetes certified      | Yes (Gardener)                                                                                                | Yes                                                         |
| Local development              | [minikube](https://minikube.sigs.k8s.io/docs/start/), [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) | [minishift](https://www.okd.io/minishift)                   |
| Proprietary extensions         | No                                                                                                            | DeploymentConfig and others                                 |
| kubectl access                 | Yes                                                                                                           | Yes                                                         |
