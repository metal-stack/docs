# GPU Support

```@contents
Pages = ["gpu-support.md"]
Depth = 5
```

For workloads which require the assistance of GPUs, support for GPUs in bare metal servers was added to metal-stack.io v0.18.0.

## GPU Operator installation

With the nvidia image a worker has basic GPU support. This means that the required kernel driver, the containerd shim and the required containerd configuration are already installed and configured.

To enable `Pods` that require GPU support to be scheduled on a worker node with a GPU, a `gpu-operator' must be installed.
This has to be done by the cluster owner after the cluster is up and running.

The simplest way to install this operator is as follows:

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

kubectl create ns gpu-operator
kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged

helm install --wait \
  --generate-name \
  --namespace gpu-operator \
  --create-namespace \
    nvidia/gpu-operator \
    --set driver.enabled=false \
    --set toolkit.enabled=false
```

After that `kubectl describe node` must show the gpu in the capacity like so:

```plain
...
Capacity:
  cpu:                64
  ephemeral-storage:  100205640Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             263802860Ki
  nvidia.com/gpu:     1
  pods:               510
...
```

With this basic installation, the worker node is ready to process GPU workloads.

!!! warning
    However, there is a caveat - only one 'Pod' can access the GPU. If this is all you need, no additional configuration is required.
    On the other hand, if you are planning to deploy multiple applications that require GPU support, and there are not that many GPUs available, you will need to configure the `gpu-operator` to allow the GPU to be shared between multiple `Pods`.

There are several approaches to sharing GPUs, please consult the official Nvidia documentation for further reference.

[https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes](https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes)
[https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html)
[https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html)

With this, happy AI processing.
