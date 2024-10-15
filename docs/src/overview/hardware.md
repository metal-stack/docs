# Hardware Support

In order to keep the automation and maintenance overhead small, we strongly advise against building highly heterogeneous environments with metal-stack. Having a lot of different vendors and server models in your partitions will heavily increase the time and effort for introducing metal-stack in your infrastructure. From experience we can tell that the interfaces for automating hardware provisioning are usually inconsistent between vendors and even between server models of the same vendor. Therefore, we encourage adopters to start off with only a small amount of machine types. If you want to be on the safe side, you should consider buying the hardware that we officially support.

We came up with a repository called [go-hal](https://github.com/metal-stack/go-hal), which includes the interface required for metal-stack to support a machine vendor. If you plan to implement support for new vendors, please check out this repository and contribute back your efforts in order to make the community benefit from extended vendor support as well.

## Servers

The following server types are officially supported and verified by the metal-stack project:

| Vendor     | Series      | Model            | Board Type     | Status      |
|------------|-------------|------------------|:---------------|:------------|
| Supermicro | Big-Twin    | SYS-2029BT-HNR   | X11DPT-B       | stable      |
| Supermicro | Big-Twin    | SYS-220BT-HNTR   | X12DPT-B6      | stable      |
| Supermicro | SuperServer | SSG-5019D8-TR12P | X11SDV-8C-TP8F | stable      |
| Supermicro | SuperServer | 2029UZ-TN20R25M  | X11DPU         | stable      |
| Supermicro | SuperServer | SYS-621C-TN12R   | X13DDW-A       | stable      |
| Supermicro | Microcloud  | 5039MD8-H8TNR    | X11SDD-8C-F    | stable      |
| Supermicro | Microcloud  | SYS-531MC-H8TNR  | X13SCD-F       | coming soon |
| Supermicro | Microcloud  | 3015MR-H8TNR     | H13SRD-F       | coming soon |
| Lenovo     | ThinkSystem | SD530            |                | alpha       |

Other server series and models might work but were not reported to us.

## GPUs

The following GPU types are officially supported and verified by the metal-stack project:

| Vendor | Model    | Status |
|--------|----------|:-------|
| NVIDIA | RTX 6000 | stable |
| NVIDIA | H100     | stable |

Other GPU models might work but were not reported to us. For a detailed description howto use GPU support in a kubernetes cluster please check this [documentation](gpu-support.md)

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

| Vendor    | Series        | Model      | OS             | Status |
|:----------|:--------------|:-----------|:---------------|:-------|
| Edge-Core | AS7700 Series | AS7712-32X | Cumulus 3.7.13 | stable |
| Edge-Core | AS7700 Series | AS7726-32X | Cumulus 4.1.1  | stable |
| Edge-Core | AS7700 Series | AS7712-32X | Edgecore SONiC | stable |
| Edge-Core | AS7700 Series | AS7726-32X | Edgecore SONiC | stable |

Other switch series and models might work but were not reported to us.

!!! warning

    On our switches we run [SONiC](https://sonicfoundation.dev). The metal-core writes network configuration specifically implemented for this operating system. Please also consider running SONiC on your switches if you do not want to run into any issues with networking.

    Our previous support for [Cumulus Linux](hhttps://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-linux/) will come to an end.

    Of course, contributions for supporting other switch vendors and operating systems are highly appreciated.

## Portable metal-stack Setup DIY

A minimal physical hardware setup may contain at least the following components:

!!! warning

    This setup should work as the components are very similar to the currently supported ones but it's currently untested.

| #  | Vendor     | Series        | Model               | Function                                                                 |
|:---|:-----------|:--------------|:--------------------|:-------------------------------------------------------------------------|
| 2x | Edge-Core  | AS5500 Series | AS5512-54x (10G)    | Leaf / Exit switches                                                     |
| 1x | Supermicro | Microcloud    | SYS-5039MA16-H12RFT | Usable machines                                                          |
| 1x | Unifi      | Edgemax       | Edgerouter Pro      | Front router for internet and out-of-band access to servers and switches |

Besides that, a 6HE rack with 1000mm depth and a portable LTE modem is needed.

This MVP will yield in 12 usable machines, one of them will be reserved as management server.
