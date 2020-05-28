# Hardware Support

In order to keep the automation and maintenance overhead small, we do not encourage highly heterogeneous environments. A lot of different vendors and server models will probably take a lot of time until having them integrated smoothly. From experience we can tell that the interfaces for controlling hardware via BMCs are typically very inconsistent between hardware vendors and even between server models. Therefore, we encourage adopters to use modular racks with a smaller amount of machine types and scale out horizontally (adding more racks when resources become scarce).

We came up with a repository called [go-hal](https://github.com/metal-stack/go-hal), which includes the interface that required for the metal-stack to support a machine vendor. If you plan to implement support for new vendors, please check out this repository and contribute back your efforts in order to make the community benefit from extended vendor support as well.

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
