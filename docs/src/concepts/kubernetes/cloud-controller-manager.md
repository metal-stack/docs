# metal-ccm

CCM stands for [cloud-controller-manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) and is the bridge between Kubernetes and a cloud-provider.

We implemented the [cloud provider interface](https://github.com/kubernetes/cloud-provider/blob/master/cloud.go) in the [metal-ccm](https://github.com/metal-stack/metal-ccm) repository. With the help of the cloud-controller-controller we provide metal-stack-specific properties for Kubernetes clusters, e.g. load balancer configuration through MetalLB or node properties.
