# HAL Improvements

Currently, we have a specific list of hardware vendors and models that we support with metal-stack.
This list is documented in [docs.metal-stack.io](https://docs.metal-stack.io/stable/overview/hardware/).

Vendor support needs to be implemented in our "hardware abstraction layer" (HAL) called [go-hal](https://github.com/metal-stack/go-hal) once the particular set of hardware arrives.

Over the past few years, it has become clear that potential users are always interested in using more and different types of hardware, either because they want to reuse their existing hardware or because their companies are tied to specific vendors.
It would be a great improvement for them to have broader support for hardware in general, similar to what is promised by projects like OpenStack Ironic.

We have found that vendor support is hard to implement and even harder to test and maintain.
We have some really sophisticated parts in our code base, reaching down to patching BIOS XMLs for individual BIOS versions of specific motherboards.
It is almost impossible to touch these pieces of code again because it could break the implementation for specific hardware.

So with this MEP, we want to evaluate ways to improve our code to make it easier to add new vendors, increase the reliability of the implementation, and provide broader hardware support more quickly.

While we continue to have a list of vendors and models for which we verified our integration works, we will also be able to say that we have general support for a number of drivers, starting with IPMI, Redfish, iDrac and Unmanaged (e.g. for developer usage in the mini-lab).

Vendors that implement these driver APIs properly may work right out of the box through our default implementation for a given driver. Through a CLI operators can quickly figure out if the existing implementation is sufficient or not. If a vendor requires specific modifications of the default implementation a dedicated vendor-overwrite can be implemented in go-hal (which will be required for Supermicro for sure).

## Shortcomings of the current implementation

- Every new vendor has to be individually whitelisted in go-hal, a new board of a Supermicro server potentially requires a pull request.
- The current interface implements functions using different underlying drivers whenever it fits, so it's not obvious if IPMI or Redfish is used, sometimes information from different protocols differ.
- There are almost no unit tests and no automated integration tests (despite indirect integration testing through our release integration, which is creating and deleting machines).
- The CLI is not implementing the entire API interface. It is implemented only roughly. To use it for testing, it requires ad hoc code changes and recompilation.
- There is no possibility for an operator to provide the user / password that a server was shipped with in order to initialize it with these credentials. Such that the metal-hammer must be booted first before it can be managed through BMC. This also implies that the implementation relies on inband to work.

## Bundling Functionality in the metal-bmc

In order to minimize the BMC interface, we should try to bundle as much of the implementation as possible in a single microservice. This microservice should have a proto / gRPC API for access.

A suitable microservice is already in place on the mgmt-servers called the [metal-bmc](https://github.com/metal-stack/metal-bmc), which can be extended for this purpose. The metal-bmc will implement the server API. The API can be called by the metal-api (indirectly through NSQ), the metal-hammer and a metal-bmc CLI.

In general, it should be preferred to run actions from remote (a.k.a outband) in order to have the functionality easily accessible for other services. Another advantage is to only bundle heavy-weight proprietary tools like `sum` in a single component. There are only few exceptions where for example an IPMI inband connection is required. For this, we need to offer a special package, which purpose can be described as enabling a server to be managed from remote. This is explained in more detail in a later section of this MEP.

## metal-bmc CLI

The CLI of the new metal-bmc API must become a first-class citizen in order to simplify testing the API. The entire new API should be generically implemented such that operators can run commands easily against a BMC.

## Additions to the metal-api

In order to have earliest possible discovery of a machine and allow potential BMC management without having to run the metal-hammer, a new table in the metal-api named `bmc` is proposed. The primary key for this table is a BMC's mac address.

This table contains the available drivers to access a machine with, which is tried to be automatically discovered through the metal-bmc. It may be that the table entries do not have an association to a machine ID directly. This is also not required in order to issue commands against the machines. A relation can be established at a later point (in most cases automatically done by the metal-hammer), such that the existing commands like `metalctl machine power/boot/...` continue to work.

## New Approach for Bootstrapping

After a server is mounted in a rack in the data center, the BMC of a server gets connected to a management switch. The BMC obtains an IP address via DHCP broadcast from a DNS server, typically running on an mgmt-server in the data center partition. Then, the metal-bmc periodically checks the DHCP lease list in order to discover new BMCs or update existing ones.

So far, nothing new here. But now it's getting different:

For every DHCP entry, the metal-bmc looks up the BMC in the new metal-api `bmc` table.

If it does not find an entity in the database, it performs an "auto discovery". In this process, the metal-bmc tries to automatically discover available BMC drivers for this server (e.g. for IPMI through RMCP like [idiscover](https://linux.die.net/man/8/idiscover), etc.).

It then reports this BMC to the metal-api containing the mac address, IP and possible drivers.

A user might provide connection details for specific drivers or select a different default driver for BMC management. It is now theoretically possible to interact with the machine BMC through the metal-api. Note that the metal-hammer was not yet involved.

If there is already an entity found in the `bmc` table, the metal-bmc attempts to update the BMC information. If, in addition to that, credentials are already provided to access the machine, the metal-bmc can additionally figure out a machine UUID related to the BMC address it can establish a relation between BMC table and machine table by updating the machine ID field in the `bmc` table and also update information about the board.

When a machine gets connected to the leaf switches and boots for the first time, the metal-hammer is run through PXE boot.

The metal-hammer gets access to the BMC API as well as to the metal-api through the pixiecore. The metal-hammer will lookup the BMC in the metal-api by the locally discovered UUID. If there is a relation between the machine and the BMC already, the metal-hammer does not need to do anything specific. It may call the new BMC API at any given point during the provisioning sequence.

If there is no relation yet, the metal-hammer attempts to establish this relation by using IPMI inband information. The metal-hammer tries to figure out the BMC mac address and attempts to generate a privileged IPMI user and password. If this works, then the metal-hammer updates the BMC table with working access credentials. This way, it is not strictly required for operators to manually insert connection data into the BMC table, but the metal-hammer can generate them through inband capabilities. If it does not work, an operator has to manually provide credentials.

From here everything should work the same as before but through remote accessing the BMC API.

## New metalctl commands

List BMCs:

```
metalctl bmc ls
MAC                 IP         VENDOR       DRIVER     MACHINE ID
27:53:57:51:6b:c8   10.0.0.8
27:53:57:51:6b:c9   10.0.0.9
92:33:b8:0e:df:8f   10.0.0.1   Supermicro   Redfish    37c43c25-69fe-4f88-b69d-4e71dc4070d0
b3:74:fc:50:76:b6   10.0.0.4   Supermicro   Redfish    4bdf5c1b-3f7d-47df-84dd-05acb6e0718d
56:62:97:4e:1f:1f   10.0.0.3   Dell         iDrac      995119fd-ec18-4cd7-8ca0-a9e1c2f70624
```

Describe a BMC:

```
metalctl bmc describe 92:33:b8:0e:df:8f
---
mac: 92:33:b8:0e:df:8f
address: 10.0.0.1
vendor: Supermicro
protocol: Redfish
machine_id: 37c43c25-69fe-4f88-b69d-4e71dc4070d0
created_at: "2024-11-19T11:15:53.760Z"
changed_at: "2024-11-19T11:18:53.760Z"
bios:
  date: 12/31/2021
  vendor: American Megatrends Inc.
  version: "3.6"
board:
  board_mfg: Supermicro
  board_part_number: X11DPT-B
  chassis_part_number: CSE-217BHQ+...
  chassis_part_serial: C217BAK18P...
  product_manufacturer: Supermicro
  product_part_number: SYS-2029BT-HNR
  product_serial: E262335X2304003C
bmc:
  version: "1.74"
ipmi:
  interface: lanplus
  port: 623
  password: abc
  user: metal
redfish:
  password: abc
  user: metal
powermetric:
  averageconsumedwatts: 70
  intervalinmin: 5
  maxconsumedwatts: 70
  minconsumedwatts: 70
  powerstate: "ON"
  powersupplies:
  - status:
      health: Critical
      state: Enabled
  - status:
      health: OK
      state: Enabled
ledstate:
  description: ""
  value: LED-OFF
```

Additional commands:

```
# establish initial access without metal-hammer
metalctl bmc create-ipmi-user 92:33:b8:0e:df:8f --ipmi-role privileged --ipmi-password 123!
# set preferred protocol
metalctl bmc update 92:33:b8:0e:df:8f --preferred-protocol IPMI
# enforce using Redfish implementation for this specific BMC
metalctl bmc update 92:33:b8:0e:df:8f --preferred-protocol Redfish --redfish-user afish --redfish-password 123!
```

## Feature Deprecation

In order to simplify the new implementation, we can deprecate some features.

### Firmware Update Functionality

This feature will be dropped because it was not completely worked out at the point of implementation. It also seems like nobody is actively using it. This brings so many challenges that we should create another MEP in order to bring it back when it's required.

### BMC Super User

This feature is a potential security issue and we primarily do it simply because the metal-bmc does not lookup the connection data from the metal-api. We should create a privileged user for operator / metal-stack component access with random credentials by the metal-hammer automatically or let the user enter these credentials manually into the new BMC table by hand.

Then we need another restricted user for machine owners in order to open serial console connections, which can be achieved through the BMC API as part of the contract.

## Testability

For the hardware support we have no particular integration testing opportunities apart from our large integration suite, which runs at the FI-TS, which is currently testing our metal-stack integration in Gardener.

In order to improve this situation, we should utilize the [IPMI simulator](https://manpages.debian.org/testing/openipmi/ipmi_sim.1.en.html) in the mini-lab and run integration tests against it. For this, [@robertvolkmann](https://github.com/robertvolkmann/) already provided a POC [here](https://github.com/robertvolkmann/clab-ipmi).

In addition to that, we need to setup a small rack with servers of individual vendors, which can be targeted from a GitHub runner. These servers should be for the sole purpose of integration testing the metal-bmc API.
