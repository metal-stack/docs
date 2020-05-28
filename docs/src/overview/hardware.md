# Hardware Support

In order to keep the automation and maintenance overhead small, we do not encourage very heterogeneous environments. A lot of different vendors and server models will probably take a lot of time until having them integrating smoothly as the interfaces to control hardware via BMC are typically very inconsistent between hardware vendors and even between server models.

We came up with a repository called [go-hal](https://github.com/metal-stack/go-hal), which includes the interface that is required for the metal-stack to support a machine vendor.

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
