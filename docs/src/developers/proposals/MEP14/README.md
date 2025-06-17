# Independence from external sources

In certain situations some customers may need to operate and create machines without making use of external services like DNS or NTP through the internet. To make this possible, all metal-stack components reaching external services need to be configurable with custom endpoints.

So far, the following components have been identified as requiring changes:

- pixiecore
- metal-hammer
- metal-images

More components are likely to be added to the list during processing.
For DNS and NTP servers it should be possible to provide default values within a partition. They can either be inherited from machines and firewalls or overwritten with own ones.

## pixiecore

A NTP server endpoint need to be configured on the pixiecore. This can be achieved by providing it through environment variables on start up.

## metal-hammer

If using a self-deployed NTP server, also the metal-hammer need to be configured with it. For backward compatibility, default values from `pool.ntp.org` and `time.google.com` are used.

## metal-images

Configurations for the `metal-images` are different for machines and firewalls.

## metalctl

In order to pass DNS and NTP servers to partitions and machines while creating them, the flags `dnsservers` and `ntpservers` need to be added.

The implementation of this MEP will make metal-stack possible to create and maintain machines without requiring an internet connection.
