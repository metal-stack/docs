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
