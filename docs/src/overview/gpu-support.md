# GPU Support

```@contents
Pages = ["gpu-support.md"]
Depth = 5
```

For workloads which require the assistance of GPUs, support for GPUs in bare metal servers was added to metal-stack.io v0.18.0.

## GPU Operator installation

With the nvidia image a worker has basic GPU support. This means that the required kernel driver, the containerd shim and the required containerd configuration are already installed and configured.

The make it possible to schedule `Pods` which require GPU support to a worker node with a GPU, a so called `gpu-operator` must be installed.
This task is required to be made by the cluster owner after the cluster is up and running.

The most simple way to install this operator is like this:

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

But there is a caveat, only one `Pod` is able to get access to the GPU. If this meets your requirements no additional configuration is required.
If you on the other hand, plan to deploy multiple applications which require GPU support and there are not so much GPUs available, you must configure the `gpu-operator` to allow to share the GPU across multiple `Pods`.

There are several approaches available for sharing GPUs, please consult the official Nvidia documentation for further reference.

[https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes](https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes)
[https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html)
[https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html)

With this, happy AI processing.