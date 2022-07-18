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
