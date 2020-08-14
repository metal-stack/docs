# Operating Systems

Our operating system images are built on regular basis from the [metal-images](https://github.com/metal-stack/metal-images) repository.

All images are hosted on GKE at [images.metal-stack.io](https://images.metal-pod.io). Feel free to use this as a mirror for your metal-stack partitions if you want. The metal-stack developers continuously have an eye on the supported images. They are updated regularly and scanned for vulnerabilities.

## Supported OS Images

The operating system images that we build are trimmed down to their bare essentials for serving as Kubernetes worker nodes. Small image sizes make machine provisioning blazingly fast.

The supported images currently are:

| Platform | Distribution | Version |
| :------- | :----------- | :------ |
| Linux    | Debian       | 10      |
| Linux    | Ubuntu       | 20.04   |

## Building Your Own Images

It is fully possible to build your own operating system images and provide them through the metal-stack.

There are some conventions though that you need to follow in order to make your image installable through the metal-hammer. You should understand the [machine provisioning sequence](architecture.md#Machine-Provisioning-Sequence-1) before starting to write your own images.

1. Images need to be compressed to a tarball using the [lz4](https://de.wikipedia.org/wiki/LZ4) compression algorithm
1. An `md5` checksum file with the same name as the image archive needs to be provided in the download path along with the actual os image
1. A `packages.txt` containing the packages contained in the OS image should be provided in the download path (not strictly required)
1. Consider semantic image versioning, which we use in our algorithms to select latest images (e.g. `os-major.minor.patch` ➡️ `ubuntu-19.10.20191018`)
1. Consider installing packages used by the metal-stack infrastructure
   - [FRR](https://frrouting.org/) to enable routing-to-the-host in our network topology
   - [go-lldpd](https://github.com/metal-stack/go-lldpd) to enable checking if the machine is still alive after user allocation
   - [ignition](https://github.com/coreos/ignition) for enabling users to run user-specific initialization instructions before bootup. It's pretty small in size, which is why we use it. However, you are free to use other cloud instance initialization tools if you want to.
1. You have to provide an `install.sh` script, which applies user-specific configuration in the installed image
   - This script should consume parameters from the `install.yaml` file that the metal-hammer writes to `/etc/metal/install.yaml`
   - Please check this contract between image and the metal-hammer [here](https://github.com/metal-stack/metal-hammer/blob/v0.5.3/cmd/install.go#L27-L46)
1. For the time being, your image must be able to support [kexec](https://en.wikipedia.org/wiki/Kexec) into the new operating system kernel, the `kexec` command is issued by the metal-hammer after running the `install.sh`. We do this because `kexec` is _much_ faster than rebooting a machine.
1. We recommend building images from Dockerfiles as it is done in [metal-images](https://github.com/metal-stack/metal-images) repository.

!!! info

    Building own operating system images is an advanced topic. When you have just started with metal-stack, we recommend using the public operating system images first.
