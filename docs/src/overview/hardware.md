# Hardware Support

In order to keep the automation and maintenance overhead small, we strongly advise against building highly heterogeneous environments with metal-stack. Having a lot of different vendors and server models in your partitions will heavily increase the time and effort for introducing metal-stack in your infrastructure. From experience we can tell that the interfaces for automating hardware provisioning are usually inconsistent between vendors and even between server models of the same vendor. Therefore, we encourage adopters to start off with only a small amount of machine types. If you want to be on the safe side, you should consider buying the hardware that we officially support.

We came up with a repository called [go-hal](https://github.com/metal-stack/go-hal), which includes the interface required for metal-stack to support a machine vendor. If you plan to implement support for new vendors, please check out this repository and contribute back your efforts in order to make the community benefit from extended vendor support as well.

## Servers

At the moment we support the following server types:

| Vendor     | Series      | Model            | Board Type     | Status |
|------------|-------------|------------------|:---------------|:-------|
| Supermicro | Big-Twin    | SYS-2029BT-HNR   | X11DPT-B       | stable |
| Supermicro | SuperServer | SSG-5019D8-TR12P | X11SDV-8C-TP8F | stable |
| Supermicro | SuperServer | 2029UZ-TN20R25M  | X11DPU         | stable |
| Supermicro | Microcloud  | 5039MD8-H8TNR    | X11SDD-8C-F    | stable |
| Lenovo     | ThinkSystem | SD530            |                | alpha  |

## Switches

At the moment we support the following switch types:

| Vendor    | Series        | Model      | OS             | Status |
| :-------- | :------------ | :--------- | :------------- | :----- |
| Edge-Core | AS7700 Series | AS7712-32X | Cumulus 3.7.13 | stable |
| Edge-Core | AS7700 Series | AS7726-32X | Cumulus 4.1.1  | stable |
| Edge-Core | AS7700 Series | AS7712-32X | Edgecore SONiC | stable |
| Edge-Core | AS7700 Series | AS7726-32X | Edgecore SONiC | stable |

!!! warning

    On our switches we run [SONiC](https://sonicfoundation.dev). The metal-core writes network configuration specifically implemented for this operating system. Please also consider running SONiC on your switches if you do not want to run into any issues with networking.

    Our previous support for [Cumulus Linux](hhttps://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-linux/) will come to an end.

    Of course, contributions for supporting other switch vendors and operating systems are highly appreciated.

## Portable metal-stack Setup DIY

A minimal physical hardware setup may contain at least the following components:

!!! warning

    This setup should work as the components are very similar to the currently supported ones but it's currently untested.

| #   | Vendor      | Series           | Model                | Function                                                                 |
| :-- | :---------- | :--------------- | :------------------- | :----------------------------------------------------------------------- |
| 2x  | Edge-Core   | AS5500 Series    | AS5512-54x (10G)     | Leaf / Exit switches                                                     |
| 1x  | Supermicro  | Microcloud       | SYS-5039MA16-H12RFT  | Usable machines                                                          |
| 1x  | Unifi       | Edgemax          | Edgerouter Pro       | Front router for internet and out-of-band access to servers and switches |

Besides that, a 6HE rack with 1000mm depth and a portable LTE modem is needed.

This MVP will yield in 12 usable machines, one of them will be reserved as management server.
