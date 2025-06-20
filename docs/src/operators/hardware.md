# Hardware Support

In order to keep the automation and maintenance overhead small, we strongly advise against building highly heterogeneous environments with metal-stack. Having a lot of different vendors and server models in your partitions will heavily increase the time and effort for introducing metal-stack in your infrastructure. From experience we can tell that the interfaces for automating hardware provisioning are usually inconsistent between vendors and even between server models of the same vendor. Therefore, we encourage adopters to start off with only a small amount of machine types. If you want to be on the safe side, you should consider buying the hardware that we officially support.

We came up with a repository called [go-hal](https://github.com/metal-stack/go-hal), which includes the interface required for metal-stack to support a machine vendor. If you plan to implement support for new vendors, please check out this repository and contribute back your efforts in order to make the community benefit from extended vendor support as well.

## Servers

The following server types are officially supported and verified by the metal-stack project:

| Vendor     | Series      | Model            | Board Type     | Status |
|------------|-------------|------------------|:---------------|:-------|
| Supermicro | Big-Twin    | SYS-2029BT-HNR   | X11DPT-B       | stable |
| Supermicro | Big-Twin    | SYS-220BT-HNTR   | X12DPT-B6      | stable |
| Supermicro | SuperServer | SSG-5019D8-TR12P | X11SDV-8C-TP8F | stable |
| Supermicro | SuperServer | 2029UZ-TN20R25M  | X11DPU         | stable |
| Supermicro | SuperServer | SYS-621C-TN12R   | X13DDW-A       | stable |
| Supermicro | Microcloud  | 5039MD8-H8TNR    | X11SDD-8C-F    | stable |
| Supermicro | Microcloud  | SYS-531MC-H8TNR  | X13SCD-F       | stable |
| Supermicro | Microcloud  | 3015MR-H8TNR     | H13SRD-F       | stable |
| Lenovo     | ThinkSystem | SD530            |                | alpha  |

Other server series and models might work but were not reported to us.

## GPUs

The following GPU types are officially supported and verified by the metal-stack project:

| Vendor | Model    | Status |
|--------|----------|:-------|
| NVIDIA | RTX 6000 | stable |
| NVIDIA | H100     | stable |

Other GPU models might work but were not reported to us. For a detailed description howto use GPU support in a kubernetes cluster please check this [documentation](../concepts/kubernetes/gpu-workers.md)

## Network Cards

The following network cards are officially supported and verified by the metal-stack project for usage in servers:

| Vendor   | Series     | Model                       | Status |
|----------|------------|-----------------------------|:-------|
| Intel    | XXV710     | DA2 DualPort 2x25G SFP28    | stable |
| Intel    | E810       | DA2 DualPort 2x25G SFP28    | stable |
| Intel    | E810       | CQDA2 DualPort 2x100G SFP28 | stable |
| Mellanox | ConnectX-5 | MCX512A-ACAT 2x25G SFP28    | stable |

## Switches

The following switch types are officially supported and verified by the metal-stack project:

| Vendor    | Series        | Model       | OS             | Status |
|:----------|:--------------|:------------|:---------------|:-------|
| Edge-Core | AS4600 Series | AS4625-54T  | Edgecore SONiC | stable |
| Edge-Core | AS4600 Series | AS4630-54TE | Edgecore SONiC | stable |
| Edge-Core | AS7700 Series | AS7712-32X  | Cumulus 3.7.13 | stable |
| Edge-Core | AS7700 Series | AS7726-32X  | Cumulus 3.7.13 | stable |
| Edge-Core | AS7700 Series | AS7712-32X  | Edgecore SONiC | stable |
| Edge-Core | AS7700 Series | AS7726-32X  | Edgecore SONiC | stable |

Other switch series and models might work but were not reported to us.

!!! warning

    On our switches we run [SONiC](https://sonicfoundation.dev). The metal-core writes network configuration specifically implemented for this operating system. Please also consider running SONiC on your switches if you do not want to run into any issues with networking.

    Our previous support for [Cumulus Linux](hhttps://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-linux/) will come to an end.

    Of course, contributions for supporting other switch vendors and operating systems are highly appreciated.

## Portable metal-stack Setup

A minimal physical hardware setup may contain at least the following components:

!!! warning

    This setup dedicated to testing environments, getting to know the metal-stack software and discussing BOMs for production setups.

| #  | Vendor     | Series        | Model               | Function                                                                 |
|:---|:-----------|:--------------|:--------------------|:-------------------------------------------------------------------------|
| 1x | EdgeCore   | AS5500 Series | AS4630-54x (1G)     | Management Switch and Management Server                                  |
| 2x | EdgeCore   | AS5500 Series | AS4625-54x (1G)     | Leaf switches                                                            |
| 1x | Supermicro | Microcloud    | 3015MR-H8TNR        | Usable machines                                                          |
| 1x | Teltonika  | Router        | RUTXR1              | Front router for internet and out-of-band access to servers and switches |

This setup will yield in 8 usable machines, one of them can be configured to provide persistent CSI storage.

![Portable metal-stack Setup](starter.jpg)