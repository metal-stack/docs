# SONiC Support

As writing this proposal, metal-stack only supports Cumulus on Broadcom ASICs. Unfortunately, after the acquisition of
Cumulus Networks by Nvidia, Broadcom decided to cut its relationship with Cumulus, and therefore Cumulus 4.2 is the last
version that supports Broadcom ASICs. Since trashing the existing hardware is not a solution, adding support for a
different network operating system is necessary.

One of the remaining big players is [SONiC](https://sonic-net.github.io/SONiC/), which Microsoft created to scale the
network of Azure. It's an open-source project and is now part of the [Linux Foundation](https://www.linuxfoundation.org/press-release/software-for-open-networking-in-the-cloud-sonic-moves-to-the-linux-foundation/).

For a general introduction to SONiC, please follow the (https://github.com/sonic-net/SONiC/wiki/Architecture) official
documentation.

## ConfigDB

On a cold start, the content of `/etc/sonic/config_db.json` will be loaded into the Redis database `CONFIG_DB`, and both
contain the switch's configuration except the BGP unnumbered configuration, which still has to be configured directly by
the frr configuration files. The SONiC community is working to remove this exception, but no release date is known.

## BGP Configuration

Frr runs inside a container, and a shell script configured it on the container startup. For BGP unnumbered, we must set
the configuration variable `docker_routing_config_mode` to `split` to prevent SONiC from overwriting our configuration
files created by `metal-core`. But by using the split mode, the integrated configuration mode of frr is deactivated, and
we have to write our BGP configuration to the daemon-specific files `bgp.conf`, `staticd.conf`, and `zebra.conf` instead
to `frr.conf`.

```shell
elif [ "$CONFIG_TYPE" == "split" ]; then
    echo "no service integrated-vtysh-config" > /etc/frr/vtysh.conf
    rm -f /etc/frr/frr.conf
```

Reference: https://github.com/Azure/sonic-buildimage/blob/202205/dockers/docker-fpm-frr/docker_init.sh#L69

Adding support for the integrated configuration mode, we must at least adjust the startup shell script and the supervisor configuration:

```
{% if DEVICE_METADATA.localhost.docker_routing_config_mode is defined and DEVICE_METADATA.localhost.docker_routing_config_mode == "unified" %}
[program:vtysh_b]
command=/usr/bin/vtysh -b
```

Reference: https://github.com/Azure/sonic-buildimage/blob/202|205/dockers/docker-fpm-frr/frr/supervisord/supervisord.conf.j2#L157

## Non-BGP Configuration

For the Non-BGP configuration we have to write it into the Redis database directly or via one of the following interfaces:

- `config replace <file>`
- the Mgmt Framework
- the SONiC restapi

Directly writing into the Redis database isn't a stable interface, and we must determine the create, delete, and update
operations on our own. The last point is also valid for the Mgmt Framework and the SONiC restapi. Furthermore, the
Mgmt Framework doesn't start anymore for several months, and a [potential fix](https://github.com/Azure/sonic-buildimage/pull/10893)
 is still not merged. And the SONiC restapi isn't enabled by default, and we must build and maintain our own SONiC images.

Using `config replace` would reduce the complexity in the `metal-core` codebase because we don't have to determine the
actual changes between the running and the desired configuration. The approach's drawbacks are using a version of SONiC
that contains the PR [Yang support for VXLAN](https://github.com/Azure/sonic-buildimage/pull/7294), and we must provide
the whole new startup configuration to prevent unwanted deconfiguration.

#### Configure Loopback interface and activate VXLAN

```json
{
 "LOOPBACK_INTERFACE": {
  "Loopback0": {},
  "Loopback0|<loopback address/32>": {}
 },
 "VXLAN_TUNNEL": {
  "vtep": {
   "src_ip": "<loopback address>"
  }
 }
}
```

#### Configure MTU

```json
{
 "PORT": {
  "Ethernet0": {
   "mtu": "9000"
  }
 }
}
```

#### Configure PXE Vlan

```json
{
 "VLAN": {
  "Vlan4000": {
   "vlanid": "4000"
  }
 },
 "VLAN_INTERFACE": {
  "Vlan4000": {},
  "Vlan4000|<metal core cidr>": {}
 },
 "VLAN_MEMBER": {
  "Vlan4000|<interface>": {
   "tagging_mode": "untagged"
  }
 },
 "VXLAN_TUNNEL_MAP": {
  "vtep|map_104000_Vlan4000": {
   "vlan": "Vlan4000",
   "vni": "104000"
  }
 }
}
```

#### Configure VRF

```json
{
 "INTERFACE": {
  "Ethernet0": {
   "vrf_name": "vrf104001"
  }
 },
 "VLAN": {
  "Vlan4001": {
   "vlanid": "4001"
  }
 },
 "VLAN_INTERFACE": {
  "Vlan4001": {
   "vrf_name": "vrf104001"
  }
 },
 "VRF": {
  "vrf104001": {
   "vni": "104001"
  }
 },
 "VXLAN_TUNNEL_MAP": {
  "vtep|map_104001_Vlan4001": {
   "vlan": "Vlan4001",
   "vni": "104001"
  }
 }
}
```

## DHCP Relay

The DHCP relay container only starts if `DEVICE_METADATA.localhost.type` is equal to `ToRRouter`.

## LLDP

SONiC always uses the local port subtype for LLDP and sets it to some freely configurable alias field of the interface.

```python
# Get the port alias. If None or empty string, use port name instead
port_alias = port_table_dict.get("alias")
if not port_alias:
    self.log_info("Unable to retrieve port alias for port '{}'. Using port name instead.".format(port_name))
    port_alias = port_name

lldpcli_cmd = "lldpcli configure ports {0} lldp portidsubtype local {1}".format(port_name, port_alias)
```

Reference: https://github.com/Azure/sonic-buildimage/blob/202205/dockers/docker-lldp/lldpmgrd#L153

## Mgmt Interface

The mgmt interface is `eth0`. To configure a static IP address and activate the Mgmt VRF, use:

```json
{
 "MGMT_INTERFACE": {
  "eth0|<mgmt cidr>": {
   "gwaddr": "<mgmt gateway>"
  }
 },
 "MGMT_VRF_CONFIG": {
  "vrf_global": {
   "mgmtVrfEnabled": "true"
  }
 }
}
```

[IP forwarding is deactivated on `eth0`](https://github.com/Azure/sonic-buildimage/blob/202205/files/image_config/sysctl/sysctl-net.conf#L7), and no IP Masquerade is configured.
