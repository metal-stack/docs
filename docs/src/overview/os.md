# Operating Systems

Our operating system images are all built from the [metal-images](https://github.com/metal-stack/metal-images) repository.

The images are hosted on GKE at images.metal-pod.io.

## Supported OS Images

The operating system images that we use are trimmed down to their bare essentials for serving as Kubernetes worker nodes. Small image sizes make our machine provisioning blazingly fast.

The following images are built, updated and scanned from the metal-stack developers on regular basis.

- Debian 10
- Ubuntu 19.10

## Building Your Own Images

It is possible to just build your own operating system images!

There are some conventions though that you need to follow in order to make your image installable through the metal-hammer.

1. TODO: Describe conventions (`install.sh, required packages, format, archive, md5 sum, ...)
