# Security Principles

metal-stack adheres to several security principles to ensure the integrity, confidentiality and availability of its services and data. These principles guide the design and implementation of security measures across the metal-stack architecture.

## Minimal Need to Know

The minimal need to know principle is a security concept that restricts access to information and resources only to those who absolutely need it for their specific role or task. This principle is implemented throughout the metal-stack architecture and operational practices to enhance security and reduce the risk of unauthorized access or data breaches.

### RBAC

!!! info

    As of now metal-stack does not implement fine-grained Role-Based Access Control (RBAC) within the `metal-api` but this is worked on in [MEP-4](../../developers/proposals/MEP4/README.md).

As described in our [User Management](../../concepts/user-management.md) concept the [metal-api](https://github.com/metal-stack/metal-api) currently offers three different user roles for authorization:

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
| [metal-metrics-exporter](https://github.com/metal-stack/metal-metrics-exporter)                                       | View  |
| [metal-ccm](https://github.com/metal-stack/metal-ccm)                                                                 | Admin |
| [pixiecore](https://github.com/metal-stack/pixie)                                                                     | View  |
| [metal-console](https://github.com/metal-stack/metal-console)                                                         | Admin |
| [cluster-api-provider-metal-stack](https://github.com/metal-stack/cluster-api-provider-metal-stack)                   | Edit  |
| [firewall-controller-manager](https://github.com/metal-stack/firewall-controller-manager)                             | Edit  |

Users can interact with the metal-api using [metalctl](https://github.com/metal-stack/metalctl), the command-line interface provided by metal-stack. Depending on the required operations, users should authenticate with the appropriate role to match their level of access.

## Defence in Depth

Defence in depth is a security strategy that employs multiple layers of defense to protect systems and data. By implementing various security measures at different levels, metal-stack aims to mitigate risks and enhance overall security posture.

## Redundancy

Redundancy is a key principle in metal-stack's security architecture. It involves duplicating critical components and services to ensure that if one fails, others can take over, maintaining system availability and reliability. This is particularly important for data storage and processing, where redundancy helps prevent data loss and ensures continuous operation.
