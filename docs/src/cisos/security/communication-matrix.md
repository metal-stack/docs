# Communication Matrix

This matrix describes the communication between components in the metal-stack and their respective security properties. Please note that depending on your setup and configuration, some components may not be present, may have different security properties and might communicate differently than described here. The communications described here represent the default configuration and setup.

**Legend**:

- `C`: Confidentiality, cryptography, encryption. Marked with an `x` if the communication is encrypted.
- `I`: Integrity of data. Marked with an `x` if the communication ensures data integrity.
- `Auth`: Authentication, ensures the identity of the communicating parties. Marked with an `x` if authentication is required.
- `Trust`: Only trusted networks involved. Marked with an `x` if the communication is only between trusted networks.

## Plain metal-stack

| No. |       Component        |      Source Zone       | Protocol |      Destination       |   Destination Zone   | Port  |  C  |  I  | Auth | Trust |            Purpose             |                      Notes                       |
| :-: | :--------------------: | :--------------------: | :------: | :--------------------: | :------------------: | :---: | :-: | :-: | :--: | :---: | :----------------------------: | :----------------------------------------------: |
|     |        metalctl        |        Internet        |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |       |          API Requests          |         Used for management operations.          |
|     |        metalctl        |        Internet        |  HTTPS   |     OIDC Provider      |       unknown        |  443  |  x  |  x  |  x   |       | Authentication & Authorization |        Optional. Needs to be configured.         |
|     |       metal-api        |  Metal Control Plane   |   TCP    |        metal-db        | Metal Control Plane  | 28015 |     |     |  x   |   x   |           RethinkDB            |                 Database access.                 |
|     |       metal-api        |  Metal Control Plane   |   TCP    |     masterdata-api     | Metal Control Plane  | 8443  |     |     |  x   |   x   |            Postgres            |                 Database access.                 |
|     |       metal-api        |  Metal Control Plane   |  HTTPS   |          ipam          | Metal Control Plane  | 9090  |     |     |      |   x   |       Address Management       |           Used to manage IP addresses.           |
|     |       metal-api        |  Metal Control Plane   |   TLS    |          nsq           | Metal Control Plane  | 4150  |  x  |  x  |  x   |   x   |       Machine Operation        |  Used for machine operations and notifications.  |
|     |       metal-api        |  Metal Control Plane   |   TLS    |      nsq lookupd       | Metal Control Plane  | 4161  |  x  |  x  |  x   |   x   |       Machine Operation        |  Used for machine operations and notifications.  |
|     |       metal-api        |  Metal Control Plane   |   HTTP   |  auditing timescaledb  | Metal Control Plane  | 5432  |     |     |  x   |   x   |           Audit Logs           | Logging of auditing events. Used for compliance. |
|     |       metal-api        |  Metal Control Plane   |  HTTPS   |       headscale        | Metal Control Plane  | 50443 |  x  |  x  |  x   |   x   |         Headscale API          |      Headscale is used for VPN networking.       |
|     |       metal-api        |  Metal Control Plane   |  HTTPS   |     S3-compatible      |       unknown        |  443  |  ?  |  ?  |  ?   |   ?   |            Firmware            |        Optional. Needs to be configured.         |
|     |       metal-api        |  Metal Control Plane   |  HTTPS   |     OIDC Provider      |       unknown        |  443  |  ?  |  ?  |  ?   |   ?   | Authentication & Authorization |        Optional. Needs to be configured.         |
|     |    metal-apiserver     |  Metal Control Plane   |   TCP    |         valkey         | Metal Control Plane  | 6379  |     |     |  x   |   x   |        Background Jobs         | Used for background job processing and caching.  |
|     |    metal-apiserver     |  Metal Control Plane   |   TCP    |        metal-db        | Metal Control Plane  | 28015 |  x  |  x  |  x   |   x   |           RethinkDB            |                 Database access.                 |
|     |    metal-apiserver     |  Metal Control Plane   |   TCP    |     masterdata-api     | Metal Control Plane  | 8080  |     |     |  x   |   x   |            Postgres            |                 Database access.                 |
|     |    metal-apiserver     |  Metal Control Plane   |  HTTPS   |          ipam          | Metal Control Plane  | 9090  |     |     |      |   x   |       Address Management       |           Used to manage IP addresses.           |
|     |    metal-apiserver     |  Metal Control Plane   |   HTTP   |  auditing timescaledb  | Metal Control Plane  | 5432  |     |     |  x   |   x   |           Audit Logs           | Logging of auditing events. Used for compliance. |
|     |    metal-apiserver     |  Metal Control Plane   |  HTTPS   |       headscale        | Metal Control Plane  | 50443 |  x  |  x  |  x   |   x   |         Headscale API          |      Headscale is used for VPN networking.       |
|     |    metal-apiserver     |  Metal Control Plane   |  HTTPS   |     OIDC Provider      |       unknown        |  443  |  x  |  x  |  x   |   ?   | Authentication & Authorization |        Optional. Needs to be configured.         |
|     |    metal-apiserver     |  Metal Control Plane   |  HTTPS   |     S3-compatible      |       unknown        |  443  |  x  |  x  |  ?   |   ?   |            Firmware            |        Optional. Needs to be configured.         |
|     |     masterdata-api     |  Metal Control Plane   |   TCP    |     masterdata-db      | Metal Control Plane  | 5432  |     |     |  x   |   x   |    Postgres database access    |                 Database access.                 |
|     |          ipam          |  Metal Control Plane   |   TCP    |        ipam-db         | Metal Control Plane  | 5432  |     |     |  x   |   x   |    Postgres database access    |                 Database access.                 |
|     | backup-restore-sidecar |  Metal Control Plane   |  HTTPS   |     S3-compatible      |       unknown        |  443  |  ?  |  ?  |  ?   |   ?   |        Backup & Restore        |        Optional. Needs to be configured.         |
|     |     metal-console      |  Partition Management  |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
|     |     metal-console      |  Partition Management  |  HTTPS   |       metal-bmc        | Partition Management |  443  |  x  |  x  |  x   |   x   |       Machine Management       |         Used for management operations.          |
|     |          ssh           |        unknown         |   TCP    |     metal-console      | Partition Management | 10001 |  x  |  x  |  x   |   ?   |      Machine Access (SSH)      |    Used to access the metal-console via SSH.     |
|     |       pixiecore        |  Partition Management  |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
|     |       metal-bmc        |  Partition Management  |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
|     |       metal-bmc        |  Partition Management  |   TLS    |          nsq           | Partition Management | 4150  |  x  |  x  |  x   |   x   |       Machine Operation        |  Used for machine operations and notifications.  |
|     | metal-cache-image-sync |  Partition Management  |  HTTPS   |     S3-compatible      |       unknown        |  443  |  ?  |  ?  |  ?   |       |     Image Caching and Sync     |        Optional. Needs to be configured.         |
|     | metal-cache-image-sync |  Partition Management  |  HTTPS   |       metal-api        |       unknown        |  443  |  x  |  x  |  x   |       |          API Requests          |         Used for management operations.          |
|     |       metal-core       | Partition Switch Plane |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
|     |      metal-hammer      |        Machine         |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
|     |      metal-hammer      |        Machine         |  HTTPS   |       pixiecore        | Partition Management |  443  |  x  |  x  |      |   x   |       Machine Management       |           Used for machine management.           |
|     |      metal-hammer      |        Machine         |  HTTPS   |       Prometheus       |       unknown        |  443  |  x  |  x  |  x   |   x   |           Monitoring           |      Actively pushes metrics to Prometheus.      |
|     |    machine firmware    |        Machine         |  HTTPS   |       pixiecore        | Partition Management |  443  |  x  |  x  |      |   x   |       Machine Management       |           Used to provision machines.            |
|     |       machine OS       |        Machine         |   DHCP   |      DHCP Server       |       Machine        | 67/68 |     |     |      |   x   |    Machine OS Provisioning     |          Used to obtain an IP address.           |
|     |       machine OS       |        Machine         |   DNS    |       DNS Server       |       Machine        |  53   |     |     |      |   x   |     Machine OS Resolution      |            Used to resolve hostnames.            |
|     |       machine OS       |        Machine         |   NTP    |       NTP Server       |       Machine        |  123  |     |     |      |   x   |      Machine OS Time Sync      |  Used to synchronize time with the NTP server.   |
|     |     kube-apiserver     |        Various         |  HTTPS   |   Container Registry   |       unknown        |  443  |  x  |  x  |  ?   |   ?   |        Container Images        |          Used to pull container images.          |
|     | metal-metrics-exporter |  Metal Control Plane   |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |           Monitoring           |         Scrapes metrics from metal-api.          |
|     |       prometheus       |  Metal Control Plane   |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |           Monitoring           |         Scrapes metrics from metal-api.          |
|     |       prometheus       |  Metal Control Plane   |  HTTPS   | metal-metrics-exporter | Metal Control Plane  | 9080  |     |     |      |   x   |           Monitoring           |   Scrapes metrics from metal-metrics-exporter.   |
|     |       prometheus       |  Metal Control Plane   |  HTTPS   |    metal-apiserver     | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |           Monitoring           |      Scrapes metrics from metal-apiserver.       |
|     |       prometheus       |  Metal Control Plane   |  HTTPS   |     masterdata-api     | Metal Control Plane  | 2113  |  x  |  x  |  x   |   x   |           Monitoring           |       Scrapes metrics from masterdata-api.       |

## With Gardener

When using metal-stack in conjunction with Gardener, the following communications will additionally be used by metal-stack components.

| No. |                 Component                 | Source Zone  | Protocol |  Destination   |  Destination Zone   | Port |  C  |  I  | Auth | Trust |   Purpose    |                    Notes                    |
| :-: | :---------------------------------------: | :----------: | :------: | :------------: | :-----------------: | :--: | :-: | :-: | :--: | :---: | :----------: | :-----------------------------------------: |
|     |                 metal-ccm                 | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |   x   | API Requests |       Used for management operations.       |
|     |        firewall-controller-manager        | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
|     |        firewall-controller-manager        | Seed Cluster |  HTTPS   | kube-apiserver |    Seed Cluster     | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
|     |        firewall-controller-manager        | Seed Cluster |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
|     |            firewall-controller            |   Firewall   |  HTTPS   | kube-apiserver |    Seed Cluster     | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
|     |            firewall-controller            |   Firewall   |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
|     |            firewall-controller            |   Firewall   |  HTTPS   | Controller URL |      Internet       | 443  |  x  |  x  |      |       | Self-Update  | Controller URL and version provided by FCM. |
|     | machine-controller-manager-provider-metal | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
|     |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
|     |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   | kube-apiserver |   Garden Cluster    | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
|     |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   | kube-apiserver |    Seed Cluster     | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
|     |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |

## With Cluster API

By using the Cluster API provider for metal-stack, the following communictations are required by metal-stack components.

| No. |            Component             |    Source Zone     | Protocol | Destination |  Destination Zone   | Port |  C  |  I  | Auth | Trust |   Purpose    |              Notes              |
| :-: | :------------------------------: | :----------------: | :------: | :---------: | :-----------------: | :--: | :-: | :-: | :--: | :---: | :----------: | :-----------------------------: |
|     |            metal-ccm             |  Workload Cluster  |  HTTPS   |  metal-api  | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests | Used for management operations. |
|     | cluster-api-provider-metal-stack | Management Cluster |  HTTPS   |  metal-api  | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests | Used for management operations. |

## With Lightbits

In order to use Lightbits as a storage solution, the following communications are required by metal-stack components.

| No. |    Component     | Source Zone  | Protocol |  Destination   | Destination Zone  | Port |  C  |  I  | Auth | Trust |   Purpose    |              Notes              |
| :-: | :--------------: | :----------: | :------: | :------------: | :---------------: | :--: | :-: | :-: | :--: | :---: | :----------: | :-----------------------------: |
|     | duros-controller | Seed Cluster |  HTTPS   |   duros-api    | Lightbits Cluster | 443  |  x  |  x  |  x   |   x   | API Requests | Used for management operations. |
|     | duros-controller | Seed Cluster |  HTTPS   | kube-apiserver |   Shoot Cluster   | 443  |  x  |  x  |  x   |       | API Requests | Used for management operations. |
