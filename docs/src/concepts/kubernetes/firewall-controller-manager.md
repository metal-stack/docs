# Firewall Management

TODO

To make the firewalls created with metal-stack easily configurable through Kubernetes resources, we add our [firewall-controller](https://github.com/metal-stack/firewall-controller) to the firewall image. The controller watches special CRDs, enabling users to manage:

- nftables rules
- Intrusion-detection with [suricata](https://suricata.io/)
- network metric collection

Please check out the [guide](../../references/external/firewall-controller/README.md) on how to use it.
