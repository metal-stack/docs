# Kubernetes Integration

With the help of the [Gardener](https://gardener.cloud/) project, metal-stack can be used for spinning up Kubernetes clusters quickly and reliably on bare metal machines.

To make this happen, we implemented a couple of components, which are described here.

```@contents
Pages = ["kubernetes.md"]
Depth = 5
```

## metal-ccm

CCM stands for [cloud-controller-manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) and is the bridge between Kubernetes and a cloud-provider.

We implemented the [cloud provider interface](https://github.com/kubernetes/cloud-provider/blob/master/cloud.go) in the [metal-ccm](https://github.com/metal-stack/metal-ccm) repository. With the help of the cloud-controller-controller we provide metal-stack-specific properties for Kubernetes clusters, e.g. load balancer configuration through MetalLB or node properties.

## firewall-controller

To make the firewalls created with metal-stack easily configurable through Kubernetes resources, we add our [firewall-controller](https://github.com/metal-stack/firewall-controller) to the firewall image. The controller watches special CRDs, enabling users to manage:

- nftables rules
- Intrusion-detection with [suricata](https://suricata.io/)
- network metric collection

Please check out the [guide](../external/firewall-controller/README.md) on how to use it.

## Gardener components

There are some Gardener resources that need be reconciled when you act as a cloud provider for the Gardener. This section briefly describes the controllers implemented for deploying Kubernetes clusters through Gardener.

If you want to learn how to deploy metal-stack with Gardener, please check out the [installation](../installation/deployment.md#Gardener-with-metal-stack-1) section.

### gardener-extension-provider-metal

The [gardener-extension-provider-metal](https://github.com/metal-stack/gardener-extension-provider-metal) contains of a set of webhooks and controllers for reconciling or mutating Gardener-specific resources.

The project also contains a validator for metal-type Gardener resources, which you should also deploy in case you want to use metal-stack in combination with Gardener.

### os-metal-extension

Due to the reason we use ignition in our operating system images for userdata, we had to provide an own extension controller for metal-stack, which you can find at Github in the [os-metal-extension](https://github.com/metal-stack/os-metal-extension) repository.

### machine-controller-manager-provider-metal

Worker nodes are managed through Gardener's [machine-controller-manager](https://github.com/gardener/machine-controller-manager) (MCM). The MCM allows out-of-tree provider implementation via sidecar, which is what we implemented in the [machine-controller-manager-provider-metal](https://github.com/metal-stack/machine-controller-manager-provider-metal) repository.


## Gardener with metal-stack

### Introduction into Gardener

[Gardener](https://gardener.cloud/) is an open-source project and a system to manage Kubernetes clusters. Based on one cluster, other K8s clusters can be created by Gardener on many different cloud providers.

### Gardener glossary

At first, the most important Gardener terms are explained. More information can also be found in the [glossary](https://github.com/gardener/documentation/blob/master/website/documentation/glossary/_index.md).

**Garden Cluster**

A dedicated Kubernetes cluster that the Gardener control plane runs in. The Kubernetes cluster can be setup e.g. with Kubespray.
The Garden cluster can also be used as seed cluster by deploying the Gardenlet into it.

**Virtual Garden**

Is a virtual cluster inside the Garden cluster. The virtual cluster is node less. Is is only a control plane node / cluster with the following components:

- garden kube-apiserver
- etcd
- kube-controller-manager

More details about the value of a virtual garden can be found in the description of [garden-setup](https://github.com/gardener/garden-setup/?tab=readme-ov-file#concept-the-virtual-cluster).

**Gardener Control Plane Components**
The control plane components exist to manage the overall creation, modification and deletion of clusters. The components are the following:

- Gardener API Server
- Gardener Controller Manager
- Gardener Scheduler
- Gardener Admission Controller

The control plane components get deployed in the `garden cluster`.

**Gardener Agent Component**
Gardener has an agent component:

- Gardenlet

The agent gets deployed in every seed cluster.

**Soil**
The soil cluster is the host for other seeds. It is the initital seed cluster, that is used for spinning up shooted seeds.

**Seed**
A cluster that hosts shoot cluster control planes as pods in order to manage shoot clusters. Taken from the [glossary](https://github.com/gardener/documentation/blob/master/website/documentation/glossary/_index.md).

**Shoot**
A Kubernetes runtime for the actual applications or services consisting of a shoot control plane running on the seed cluster and worker nodes hosting the actual workload. Taken from the [glossary](https://github.com/gardener/documentation/blob/master/website/documentation/glossary/_index.md).

---

### Initial Cluster Setup

Before creating the `garden cluster`, a base K8s cluster need to be in place:
Some suggestions for the initial K8s cluster:

- GCP/GKE
- metalstack.cloud
- Kubespray

**Initial Cluster on GCP**

- A GCP account need to be in place
- Ansible [GCP auth role](https://github.com/metal-stack/ansible-common/tree/master/roles/gcp-auth) can be used for authenticating against GCP
- Ansible [GCP create cluster role](https://github.com/metal-stack/ansible-common/tree/master/roles/gcp-create) can be used for creating the GCP cluster. 

Suggestions for default values are:
  - `gcp_machine_type`: e2-standard-8
  - `gcp_autoscaling_min_nodes`: 1
  - `gcp_autoscaling_max_nodes`: 3

**Initial Cluster on metalstack.cloud**

- A Kubernetes cluster can be created on [metalstack.cloud](https://metalstack.cloud/de/documentation/UserManual#creating-a-cluster) via UI, CLI or Terraform

**Initial Cluster on a dedicated host via Kubespray**

- Could be done with Ansible and the default values for a cluster provided by [Kubespray](https://github.com/kubernetes-sigs/kubespray/blob/master/playbooks/cluster.yml)

### metal-stack Setup

> **Attention:** Bootstrapping a meta-stack partition is out of scope and need to be done before focusing on the relationship between metal-stack and Gardener. This guide assumes a metal-stack partition (servers, switches, network, ...) is already in place.

Start by deploying:

- `ingress-nginx-controller`
- `cert-manager`

This guide assumes, that metal-stack gets deployed on the same initial cluster as Gardener. On the initial cluster, the metal-stack control plane need to be deployed. This can be done as described in the metal-stack [documentation](https://docs.metal-stack.io/stable/installation/deployment/#Metal-Control-Plane-Deployment).

### Garden Cluster Setup

After setting up the initial K8s cluster and metal-stack, Gardener can be deployed with the [Gardener Ansible role](https://github.com/metal-stack/metal-roles/tree/master/control-plane/roles/gardener).
This deploys the following components:

  - virtual garden
  - Gardener control plane components
  - soil cluster
  - managed seed cluster (into the metal-stack partition)

In summary, this results in the following:

 - `Garden cluster` created in the initial cluster
 - `soil cluster` created in the initial cluster. This will be the `initial seed` used for spinning up `shooted seeds` in the metal-stack partition
 - `shooted seed` inside the metal-stack partition, where all `shoots` are derived from
