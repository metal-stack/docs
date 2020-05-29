# Hardware Support

In order to keep the automation and maintenance overhead small, we strongly advise against building highly heterogeneous environments with metal-stack. Having a lot of different vendors and server models in your partitions will heavily increase the effort to introduce metal-stack in your environment. From experience we can tell that the interfaces for automating hardware provisioning are usually inconsistent between vendors and even between server models of the same vendor. Therefore, we encourage adopters to use racks with a small amount of machine types. If you want to be on the safe side, you should consider buying the hardware that we officially support.

We came up with a repository called [go-hal](https://github.com/metal-stack/go-hal), which includes the interface required for metal-stack to support a machine vendor. If you plan to implement support for new vendors, please check out this repository and contribute back your efforts in order to make the community benefit from extended vendor support as well.

## Servers

At the moment we support the following server types:

| Vendor     | Series | Model |
|:---------- |:------ |:----- |
| Supermicro | TODO   | TODO  |

## Switches

At the moment we support the following switch types:

| Vendor   | Series | Model |
|:-------- |:------ |:----- |
| Edgecore | TODO   | TODO  |
