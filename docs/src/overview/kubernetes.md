# Kubernetes Integration

One of the main motivations for starting with metal-stack was to use it as a foundation for provisioning Kubernetes clusters. In this chapter, we explain how we integrated metal-stack to set up fully automated provisioning of Kubernetes clusters, including autoscaling capabilities.

```@contents
Pages = ["kubernetes.md"]
Depth = 5
```

## metal-stack Components for Kubernetes Integration

The following components are generic, meaning that they are independent of the chosen Kubernetes orchestration engine.

### metal-ccm

CCM stands for [cloud-controller-manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) and is the bridge between Kubernetes and a cloud-provider.

We implemented the [cloud provider interface](https://github.com/kubernetes/cloud-provider/blob/master/cloud.go) in the [metal-ccm](https://github.com/metal-stack/metal-ccm) repository. With the help of the cloud-controller-controller we provide metal-stack-specific properties for Kubernetes clusters, e.g. load balancer configuration through MetalLB or node properties.

### firewall-controller

To make the firewalls created with metal-stack easily configurable through Kubernetes resources, we add our [firewall-controller](https://github.com/metal-stack/firewall-controller) to the firewall image. The controller watches special CRDs, enabling users to manage:

- nftables rules
- Intrusion-detection with [suricata](https://suricata.io/)
- network metric collection

Please check out the [guide](../external/firewall-controller/README.md) on how to use it.

## Gardener

[Gardener](https://gardener.cloud/) is an open source project for orchestrated Kubernetes cluster provisioning. It supports many different cloud providers, metal-stack being one of them. Using the Gardener project, metal-stack can act as a machine provider for Kubernetes worker nodes.

The idea behind the Gardener project is to start with a dedicated set of Kubernetes clusters (this can be a single cluster, too), which are used to host Kubernetes control planes for new Kubernetes clusters. The new Kubernetes control planes reside in dedicated namespaces of the initial clusters ("Kubernetes in Kubernetes" or "underlay / overlay Kubernetes"). Where initial clusters come from is the subject of a larger debate, with suggestions made in a later section of this document.

Gardener's architecture is designed for multi-tenant environments, with a strong distinction between the operator and the end users. In Gardener, Kubernetes control planes for different tenants may reside in the same operator cluster. This approach makes it very suitable for being used with bare metal because it allows taking full advantage of the server resources. Another implication is that end users do not have access to their control plane components, such as the kube-apiserver or the ETCD. These are managed by the operator and in case of metal-stack even physically divided from the end user's workload.

Gardener allocates machines from a cloud provider and automatically deploys a kubelet to those nodes, which then joins the appropriate control plane. Operators can also nest clusters so that newly provisioned clusters can be used to spin up more clusters, leading to nearly infinite scalability (also known as "kubeception" model).

### Terminology

We would like to explain the most important Gardener terms. The terminology used in the Gardener project has many similarities to the architecture of Kubernetes. Additional information can also be found in the [official glossary](https://github.com/gardener/documentation/blob/master/website/documentation/glossary/_index.md).

#### Garden Cluster

The Garden Cluster is a Kubernetes cluster that runs the Gardener Control Plane.

The control plane components introduce dedicated Kubernetes API resources for provisioning new Kubernetes clusters with the Gardener. It also takes care of the validation for many of those Gardener API resources and also reconciling some of them. The components are the following:

- Gardener API Server
- Gardener Controller Manager
- Gardener Scheduler
- Gardener Admission Controller

The control plane components can be deployed in the Garden Cluster through the Gardener Operator.

The Garden cluster can also be used as [seed](#seeds-and-soils) cluster.

#### Virtual Garden

A recommended way to deploy the Gardener is running a "virtual cluster" inside the Garden cluster. It is basically a Kubernetes control plane without any worker nodes, providing the Kubernetes API in an own ETCD. Its purpose is to store all Gardener resources (such that they reside inside a dedicated ETCD) and provide an individual update lifecycle from the Garden Cluster. End users can have access to own project namespaces in the virtual garden, too.

The virtual garden consists of the following components:

- garden kube-apiserver
- etcd
- kube-controller-manager

More details about the virtual garden can be found in the description of [`gardener-operator`](https://github.com/gardener/gardener/blob/master/docs/concepts/operator.md).

#### Seeds and Soils

A seed cluster is a cluster in which an agent component called the `Gardenlet` is running. The gardenlet is connected to the Gardener Control Plane and is responsible for orchestrating the provisioning of new clusters inside the seed cluster. The control plane components for the new clusters run as pods in the seed cluster.

A seed cluster can also be called a soil if the Gardenlet has been manually deployed by the operator and not by the Gardener. Clusters created on the soil can be turned into seed clusters by the operator using a Gardener resource called `ManagedSeed`. This resource causes Gardener to automatically deploy the Gardenlet to the new cluster, such that the resulting cluster is not called a soil.

#### Shoot

Every Kubernetes cluster that is fully provisioned and managed by Gardener is called a `Shoot` cluster. It consists of the shoot control plane running on the seed cluster and worker nodes running the actual workload.

### Gardener Integration Components

During the provisioning flow of a cluster, Gardener emits resources that are expected to be reconciled by controllers of a cloud provider. This section briefly describes the controllers implemented by metal-stack to allow the creation of a Kubernetes cluster on metal-stack infrastructure.

If you want to learn how to deploy metal-stack with Gardener, please check out the [installation](../installation/deployment.md#Gardener-with-metal-stack-1) section.

#### gardener-extension-provider-metal

The [gardener-extension-provider-metal](https://github.com/metal-stack/gardener-extension-provider-metal) contains of a set of webhooks and controllers for reconciling cloud provider specific resources of `type: Metal`, which created by Gardener during the cluster provisioning flow.

Primarily, its purpose is to reconcile `Infrastructure`, `ControlPlane`, and `Worker` resources.

The project also introduces an own API (`ProviderConfiguration` resources) and consists of an admission-controller to validate them. This admission controller should be deployed in the Gardener control plane cluster.

#### os-metal-extension

Due to the reason metal-stack initially used ignition to provision operating system images (today, cloud-init is supported as well) there is an implementation of a controller that translates the generic `OperatingSystemConfig` format of Gardener into ignition userdata. It can be found on Github in the [os-metal-extension](https://github.com/metal-stack/os-metal-extension) repository.

#### machine-controller-manager-provider-metal

Worker nodes are managed through Gardener's [machine-controller-manager](https://github.com/gardener/machine-controller-manager) (MCM). The MCM allows out-of-tree provider implementation via sidecar, which is what we implemented in the [machine-controller-manager-provider-metal](https://github.com/metal-stack/machine-controller-manager-provider-metal) repository.

### Initial Cluster Setup

Before creating the `garden cluster`, a base K8s cluster needs to be in place.
Some suggestions for the initial K8s cluster are:

- GCP/GKE
- metalstack.cloud

#### Initial Cluster on GCP

- A GCP account needs to be in place.
- The Ansible [gcp-auth role](https://github.com/metal-stack/ansible-common/tree/master/roles/gcp-auth) can be used for authenticating against GCP.
- The Ansible [gcp-create role](https://github.com/metal-stack/ansible-common/tree/master/roles/gcp-create) can be used for creating a GKE cluster.

Suggestions for default values are:

  - `gcp_machine_type`: e2-standard-8
  - `gcp_autoscaling_min_nodes`: 1
  - `gcp_autoscaling_max_nodes`: 3

#### Initial Cluster on metalstack.cloud

- A Kubernetes cluster can be created on [metalstack.cloud](https://metalstack.cloud/de/documentation/UserManual#creating-a-cluster) via UI, CLI or Terraform.

### metal-stack Setup

> **Attention:** Bootstrapping a metal-stack partition is out of scope and need to be done before focusing on the relationship between metal-stack and Gardener. This guide assumes a metal-stack partition (servers, switches, network, ...) is already in place.

Start by deploying:

- `ingress-nginx-controller`
- `cert-manager`

This guide assumes, that metal-stack gets deployed on the same initial cluster as Gardener. On the initial cluster, the metal-stack control plane need to be deployed. This can be done as described in the metal-stack [documentation](https://docs.metal-stack.io/stable/installation/deployment/#Metal-Control-Plane-Deployment).

#### Garden Cluster Setup

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
