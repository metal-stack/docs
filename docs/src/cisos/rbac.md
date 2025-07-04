# RBAC

The [metal-api](https://github.com/metal-stack/metal-api) offers three different user roles for authorization:

- `Admin`
- `Edit`
- `View`

To ensure that internal components interact securely with the metal-api, metal-stack assigns specific roles to each service based on the principle of least privilege.

| Component                                                                                                             | Role  |
|-----------------------------------------------------------------------------------------------------------------------|-------|
| [metal-image-cache-sync](https://github.com/metal-stack/metal-image-cache-sync)                                       | View  |
| [machine-controller-manager-provider-metal](https://github.com/metal-stack/machine-controller-manager-provider-metal) | Edit  |
| [gardener-extension-provider-metal](https://github.com/metal-stack/gardener-extension-provider-metal)                 | Edit  |
| [metal-bmc](https://github.com/metal-stack/metal-bmc)                                                                 | Edit  |
| [metal-core](https://github.com/metal-stack/metal-core)                                                               | Edit  |
| [metal-hammer](https://github.com/metal-stack/metal-hammer/)                                                          | View  |
| [metal-metrics-exporter](https://github.com/metal-stack/metal-metrics-exporter)                                       | Admin |
| [metal-ccm](https://github.com/metal-stack/metal-ccm)                                                                 | Admin |
| [pixiecore](https://github.com/metal-stack/pixie)                                                                     | View  |
| [metal-console](https://github.com/metal-stack/metal-console)                                                         | Admin |
| [cluster-api-provider-metal-stack](https://github.com/metal-stack/cluster-api-provider-metal-stack)                   | Edit  |
| [firewall-controller-manager](https://github.com/metal-stack/firewall-controller-manager)                             | Edit  |

Users can interact with the metal-api using [metalctl](https://github.com/metal-stack/metalctl), the command-line interface provided by metal-stack. Depending on the required operations, users should authenticate with the appropriate role to match their level of access.

As part of [MEP-4](../developers/proposals/MEP4/README.md), significant work is underway to introduce more fine-grained access control mechanisms within metal-stack, enhancing the precision and flexibility of permission management.