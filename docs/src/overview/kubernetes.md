# Kubernetes Integration

With the help of the [Gardener](https://gardener.cloud/) project, metal-stack can be used for spinning up Kubernetes clusters quickly and reliably on bare metal machines.

To make this happen, we implemented a couple of components, which are described here.

## Kubernetes related components

### metal-ccm

CCM stands for [cloud-controller-manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) and is the bridge between Kubernetes and a cloud-provider.

We implemented the cloud provider interface in the [metal-ccm](https://github.com/metal-stack/metal-ccm) repository. With the help of the controller we provide metal-stack-specific properties for Kubernetes clusters, e.g. load balancer configuration through MetalLB or node properties.

### csi-lvm

When dealing with local storage, it can be pretty useful not to write directly on to the host system using hostpath. Instead, we wrote a storage plugin that enables your pods to write to logical volumes.

Checkout the csi-lvm repository [here](https://github.com/metal-stack/csi-lvm).

## Gardener related components

## gardener-extension-provider-metal

## os-metal-extension
