# Storage

When working with bare-metal servers, providing cloud storage is a challenge. With physical machines there is no opportunity that a hypervisor can mount storage devices into the servers and thus, we have to implement other mechanisms that are capable of dynamically mounting storage onto the machines.

In the meantime, we have started to integrate third-party solutions into our metal-stack landscape. They help us to provide modern, well-integrated and scalable storage solutions to our end-users.

```@contents
Pages = ["persistent_storage.md"]
Depth = 5
```

## Lightbits Labs NVMe over TCP Storage Integration

[Lightbits Labs](https://www.lightbitslabs.com/nvme-over-tcp/) offers a proprietary implementation of persistent storage using NVMe over TCP. The solution has some very superior traits that fit very well to metal-stack. The strongest advantages are:

- High performance
- Built-in multi-tenant capabilities
- Configurable compression and replication factors

We are maintaining an open source integration for running LightOS in our [Gardener](gardener.md) cluster provisioning. You can enable it through the controller registration of the [gardener-extension-provider-metal](https://github.com/metal-stack/gardener-extension-provider-metal).

With the integration in place, the extension-provider deploys a [duros-controller](https://github.com/metal-stack/duros-controller) along with a Duros Storage CRD into the seed's shoot namespace. The duros-controller takes care of creating projects and managing credentials at the Lightbits Duros API. It also provides storage classes as configured in the extension-provider's controller registration to the customer's shoot cluster such that users can start consuming the Lightbits storage immediately.

## Simple Node Local Storage with csi-driver-lvm

If you wish to quickly start off with cluster provisioning without caring so much about complex cloud storage solutions, we recommend using a small storage driver we wrote called [csi-driver-lvm](https://github.com/metal-stack/csi-driver-lvm). It provides a storage class that manages node-local storage through [LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)).

A definition of a PVC can look like this:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
  storageClassName: csi-lvm-sc-linear
```

The solution does not provide cloud-storage or whatsoever, but it improves the user's accessibility of local storage on bare-metal machines through Kubernetes. Check out the driver's documentation [here](../../references/external/csi-driver-lvm/README.md).
