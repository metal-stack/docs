# Operating Systems

Our operating system images are built on regular basis from the [metal-images](https://github.com/metal-stack/metal-images) repository.

All images are hosted on GKE at [images.metal-pod.io](https://images.metal-pod.io). Feel free to use this as a mirror for your metal-stack partitions if you want. The metal-stack developers continuously have an eye on the supported images. They are updated regularly and scanned for vulnerabilities.

## Supported OS Images

The operating system images that we build are trimmed down to their bare essentials for serving as Kubernetes worker nodes. Small image sizes make machine provisioning blazingly fast.

The supported images currently are:

- Debian 10
- Ubuntu 19.10

## Building Your Own Images

It is fully possible to build your own operating system images and provide them through the metal-stack.

There are some conventions though that you need to follow in order to make your image installable through the metal-hammer.

1. TODO: Describe conventions (`install.sh`, required packages, format, archive, md5 sum, ...)
