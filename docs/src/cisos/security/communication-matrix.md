# Communication Matrix

This matrix describes the communication between components in the metal-stack and their respective security properties. Please note that depending on your setup and configuration, some components may not be present, may have different security properties and might communicate differently than described here. The communication processes described here correspond to the standard configuration and setup.

**Legend**:

- `C`: Confidentiality, cryptography, encryption. Marked with an `x` if the communication is encrypted.
- `I`: Integrity of data. Marked with an `x` if the communication ensures data integrity.
- `Auth`: Authentication, ensures the identity of the communicating parties. Marked with an `x` if authentication is required.
- `Trust`: Only trusted networks involved. Marked with an `x` if the communication is only between trusted networks.

## Plain metal-stack

!!! info

    The following table might not be displayed in completeness. Scroll to the right to see all entries.

| No.  |       Component        |      Source Zone       | Protocol |      Destination       |   Destination Zone   | Port  |  C  |  I  | Auth | Trust |            Purpose             |                      Notes                       |
| :--: | :--------------------: | :--------------------: | :------: | :--------------------: | :------------------: | :---: | :-: | :-: | :--: | :---: | :----------------------------: | :----------------------------------------------: |
| 1.1  |        metalctl        |        Internet        |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |       |          API Requests          |         Used for management operations.          |
| 1.2  |        metalctl        |        Internet        |  HTTPS   |     OIDC Provider      |       unknown        |  443  |  x  |  x  |  x   |       | Authentication & Authorization |        Optional. Needs to be configured.         |
| 1.3  |        metalctl        |        Internet        |  HTTPS   |         GitHub         |       Internet       |  443  |  x  |  x  |      |       |            Updater             |       Used for updates and version checks.       |
| 2.1  |       metal-api        |  Metal Control Plane   |   TCP    |        metal-db        | Metal Control Plane  | 28015 |     |     |  x   |   x   |           RethinkDB            |                 Database access.                 |
| 2.2  |       metal-api        |  Metal Control Plane   |   TCP    |     masterdata-api     | Metal Control Plane  | 8443  |     |     |  x   |   x   |            Postgres            |                 Database access.                 |
| 2.3  |       metal-api        |  Metal Control Plane   |   HTTP   |          ipam          | Metal Control Plane  | 9090  |     |     |      |   x   |       Address Management       |           Used to manage IP addresses.           |
| 2.4  |       metal-api        |  Metal Control Plane   |   TLS    |          nsq           | Metal Control Plane  | 4150  |  x  |  x  |  x   |   x   |       Machine Operation        |  Used for machine operations and notifications.  |
| 2.5  |       metal-api        |  Metal Control Plane   |   HTTP   |      nsq lookupd       | Metal Control Plane  | 4161  |     |     |  x   |   x   |       Machine Operation        |  Used for machine operations and notifications.  |
| 2.6  |       metal-api        |  Metal Control Plane   |   TCP    |  auditing timescaledb  | Metal Control Plane  | 5432  |     |     |  x   |   x   |           Audit Logs           | Logging of auditing events. Used for compliance. |
| 2.7  |       metal-api        |  Metal Control Plane   |  HTTPS   |       headscale        | Metal Control Plane  | 50443 |  x  |  x  |  x   |   x   |         Headscale API          |      Headscale is used for VPN networking.       |
| 2.8  |       metal-api        |  Metal Control Plane   |  HTTPS   | S3-compatible Storage  |       unknown        |  443  |  ?  |  ?  |  ?   |   ?   |            Firmware            |        Optional. Needs to be configured.         |
| 2.9  |       metal-api        |  Metal Control Plane   |  HTTPS   |     OIDC Provider      |       unknown        |  443  |  ?  |  ?  |  ?   |   ?   | Authentication & Authorization |        Optional. Needs to be configured.         |
| 3.1  |    metal-apiserver     |  Metal Control Plane   |   TCP    |         valkey         | Metal Control Plane  | 6379  |     |     |  x   |   x   |        Background Jobs         | Used for background job processing and caching.  |
| 3.2  |    metal-apiserver     |  Metal Control Plane   |   TCP    |        metal-db        | Metal Control Plane  | 28015 |  x  |  x  |  x   |   x   |           RethinkDB            |                 Database access.                 |
| 3.3  |    metal-apiserver     |  Metal Control Plane   |   TCP    |     masterdata-api     | Metal Control Plane  | 8080  |     |     |  x   |   x   |            Postgres            |                 Database access.                 |
| 3.4  |    metal-apiserver     |  Metal Control Plane   |   HTTP   |          ipam          | Metal Control Plane  | 9090  |     |     |      |   x   |       Address Management       |           Used to manage IP addresses.           |
| 3.5  |    metal-apiserver     |  Metal Control Plane   |   TCP    |  auditing timescaledb  | Metal Control Plane  | 5432  |     |     |  x   |   x   |           Audit Logs           | Logging of auditing events. Used for compliance. |
| 3.6  |    metal-apiserver     |  Metal Control Plane   |  HTTPS   |       headscale        | Metal Control Plane  | 50443 |  x  |  x  |  x   |   x   |         Headscale API          |      Headscale is used for VPN networking.       |
| 3.7  |    metal-apiserver     |  Metal Control Plane   |  HTTPS   |     OIDC Provider      |       unknown        |  443  |  x  |  x  |  x   |   ?   | Authentication & Authorization |        Optional. Needs to be configured.         |
| 3.8  |    metal-apiserver     |  Metal Control Plane   |  HTTPS   | S3-compatible Storage  |       unknown        |  443  |  x  |  x  |  ?   |   ?   |            Firmware            |        Optional. Needs to be configured.         |
| 4.1  |     masterdata-api     |  Metal Control Plane   |   TCP    |     masterdata-db      | Metal Control Plane  | 5432  |     |     |  x   |   x   |    Postgres database access    |                 Database access.                 |
| 5.1  |          ipam          |  Metal Control Plane   |   TCP    |        ipam-db         | Metal Control Plane  | 5432  |     |     |  x   |   x   |    Postgres database access    |                 Database access.                 |
| 6.1  | backup-restore-sidecar |  Metal Control Plane   |  HTTPS   | S3-compatible Storage  |       unknown        |  443  |  ?  |  ?  |  ?   |   ?   |        Backup & Restore        |        Optional. Needs to be configured.         |
| 6.2  | backup-restore-sidecar |  Metal Control Plane   |  HTTPS   |       Google API       |       Internet       |  443  |  x  |  x  |  x   |       |        Backup & Restore        |        Optional. Needs to be configured.         |
| 6.3  | backup-restore-sidecar |  Metal Control Plane   |   TCP    |        Postgres        | Metal Control Plane  | 5432  |     |     |  x   |   x   |        Backup & Restore        |        Optional. Needs to be configured.         |
| 6.4  | backup-restore-sidecar |  Metal Control Plane   |   TCP    |       RethinkDB        | Metal Control Plane  | 28015 |     |     |  x   |   x   |        Backup & Restore        |        Optional. Needs to be configured.         |
| 6.5  | backup-restore-sidecar |  Metal Control Plane   |   TCP    |          ETCD          | Metal Control Plane  | 2380  |     |     |  x   |   x   |        Backup & Restore        |        Optional. Needs to be configured.         |
| 6.6  | backup-restore-sidecar |  Metal Control Plane   |   TCP    |         Redis          | Metal Control Plane  | 6379  |     |     |  x   |   x   |        Backup & Restore        |        Optional. Needs to be configured.         |
| 6.7  | backup-restore-sidecar |  Metal Control Plane   |   TCP    |         keydb          | Metal Control Plane  | 6379  |     |     |  x   |   x   |        Backup & Restore        |        Optional. Needs to be configured.         |
| 7.1  |     metal-console      |  Partition Management  |   HTTP   |       metal-api        | Metal Control Plane  | 8080  |     |     |  x   |   x   |          API Requests          |         Used for management operations.          |
| 7.2  |     metal-console      |  Partition Management  |  HTTPS   |       metal-bmc        | Partition Management | 3333  |  x  |  x  |  x   |   x   |       Machine Management       |         Used for management operations.          |
| 8.1  |          ssh           |        unknown         |   TCP    |     metal-console      | Partition Management | 10001 |  x  |  x  |  x   |   ?   |      Machine Access (SSH)      |    Used to access the metal-console via SSH.     |
| 9.1  |       pixiecore        |  Partition Management  |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
| 10.1 |       metal-bmc        |  Partition Management  |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
| 10.2 |       metal-bmc        |  Partition Management  |   TLS    |          nsq           | Partition Management | 4150  |  x  |  x  |  x   |   x   |       Machine Operation        |  Used for machine operations and notifications.  |
| 10.2 |       metal-bmc        |  Partition Management  |   IPMI   |      machine BMC       |       Machine        |  623  |     |     |  x   |   x   |       Machine Operation        |             Used for BMC management.             |
| 11.1 | metal-cache-image-sync |  Partition Management  |  HTTPS   | S3-compatible Storage  |       unknown        |  443  |  ?  |  ?  |  ?   |       |     Image Caching and Sync     |        Optional. Needs to be configured.         |
| 11.2 | metal-cache-image-sync |  Partition Management  |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |       |          API Requests          |         Used for management operations.          |
| 12.1 |       metal-core       | Partition Switch Plane |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
| 12.2 |       metal-core       | Partition Switch Plane |   TCP    |  SONiC ConfigDB Redis  |        Switch        | 6379  |     |     |      |   x   |          API Requests          |         Used for management operations.          |
| 13.1 |      metal-hammer      |        Machine         |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |          API Requests          |         Used for management operations.          |
| 13.2 |      metal-hammer      |        Machine         |  HTTPS   |       pixiecore        | Partition Management |  443  |  x  |  x  |      |   x   |       Machine Management       |           Used for machine management.           |
| 13.3 |      metal-hammer      |        Machine         |  HTTPS   |       Prometheus       |       unknown        |  443  |  x  |  x  |  x   |   x   |           Monitoring           |      Actively pushes metrics to Prometheus.      |
| 13.4 |      metal-hammer      |        Machine         |   HTTP   |        HAProxy         | Metal Control Plane  | 9001  |     |  x  |      |   x   |   Image Caching and Pulling    |         Used to pull images via HAProxy.         |
| 13.5 |      metal-hammer      |        Machine         |  HTTPS   |   Container Registry   |       internet       |  443  |  x  |  x  |  ?   |       |       Image and Pulling        |      Used to pull images from the registry.      |
| 14.1 |    machine firmware    |        Machine         |  HTTPS   |       pixiecore        | Partition Management |  443  |  x  |  x  |      |   x   |       Machine Management       |           Used to provision machines.            |
| 14.2 |    machine firmware    |        Machine         |   TFTP   |       pixiecore        | Partition Management |  69   |     |     |      |   x   |    Machine OS Provisioning     |       Used to provision machine firmware.        |
| 15.1 |       machine OS       |        Machine         |   DHCP   |      DHCP Server       |       Machine        | 67/68 |     |     |      |   x   |    Machine OS Provisioning     |          Used to obtain an IP address.           |
| 15.2 |       machine OS       |        Machine         |   DNS    |       DNS Server       |       Machine        |  53   |     |     |      |   x   |     Machine OS Resolution      |            Used to resolve hostnames.            |
| 15.3 |       machine OS       |        Machine         |   NTP    |       NTP Server       |       Machine        |  123  |     |     |      |   x   |      Machine OS Time Sync      |  Used to synchronize time with the NTP server.   |
| 16.1 |     kube-apiserver     |        Various         |  HTTPS   |   Container Registry   |       unknown        |  443  |  x  |  x  |  ?   |   ?   |        Container Images        |          Used to pull container images.          |
| 17.1 | metal-metrics-exporter |  Metal Control Plane   |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |           Monitoring           |         Scrapes metrics from metal-api.          |
| 18.1 |       prometheus       |  Metal Control Plane   |  HTTPS   |       metal-api        | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |           Monitoring           |         Scrapes metrics from metal-api.          |
| 18.2 |       prometheus       |  Metal Control Plane   |  HTTPS   | metal-metrics-exporter | Metal Control Plane  | 9080  |     |     |      |   x   |           Monitoring           |   Scrapes metrics from metal-metrics-exporter.   |
| 18.3 |       prometheus       |  Metal Control Plane   |  HTTPS   |    metal-apiserver     | Metal Control Plane  |  443  |  x  |  x  |  x   |   x   |           Monitoring           |      Scrapes metrics from metal-apiserver.       |
| 18.4 |       prometheus       |  Metal Control Plane   |  HTTPS   |     masterdata-api     | Metal Control Plane  | 2113  |  x  |  x  |  x   |   x   |           Monitoring           |       Scrapes metrics from masterdata-api.       |

## With Gardener

When using metal-stack in conjunction with Gardener, the following communications will additionally be used by metal-stack components.

!!! info

    The following table might not be displayed in completeness. Scroll to the right to see all entries.

| No.  |                 Component                 | Source Zone  | Protocol |  Destination   |  Destination Zone   | Port |  C  |  I  | Auth | Trust |   Purpose    |                    Notes                    |
| :--: | :---------------------------------------: | :----------: | :------: | :------------: | :-----------------: | :--: | :-: | :-: | :--: | :---: | :----------: | :-----------------------------------------: |
| G1.1 |                 metal-ccm                 | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |   x   | API Requests |       Used for management operations.       |
| G1.2 |                 metal-ccm                 | Seed Cluster |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |   x   | API Requests |       Used for management operations.       |
| G2.1 |        firewall-controller-manager        | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
| G2.2 |        firewall-controller-manager        | Seed Cluster |  HTTPS   | kube-apiserver |    Seed Cluster     | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
| G2.3 |        firewall-controller-manager        | Seed Cluster |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
| G3.1 |            firewall-controller            |   Firewall   |  HTTPS   | kube-apiserver |    Seed Cluster     | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
| G3.2 |            firewall-controller            |   Firewall   |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |   x   | API Requests |        Used for firewall management.        |
| G3.3 |            firewall-controller            |   Firewall   |  HTTPS   | Controller URL |      Internet       | 443  |  x  |  x  |      |       | Self-Update  | Controller URL and version provided by FCM. |
| G4.1 | machine-controller-manager-provider-metal | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
| G5.1 |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
| G5.2 |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   | kube-apiserver |   Garden Cluster    | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
| G5.3 |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   | kube-apiserver |    Seed Cluster     | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |
| G5.4 |     gardener-extension-provider-metal     | Seed Cluster |  HTTPS   | kube-apiserver |    Shoot Cluster    | 443  |  x  |  x  |  x   |       | API Requests |       Used for management operations.       |

## With Cluster API

By using the Cluster API provider for metal-stack, the following communictations are required by metal-stack components.

!!! info

    The following table might not be displayed in completeness. Scroll to the right to see all entries.

| No.  |            Component             |    Source Zone     | Protocol |  Destination   |  Destination Zone   | Port |  C  |  I  | Auth | Trust |   Purpose    |              Notes              |
| :--: | :------------------------------: | :----------------: | :------: | :------------: | :-----------------: | :--: | :-: | :-: | :--: | :---: | :----------: | :-----------------------------: |
| C1.1 |            metal-ccm             |  Workload Cluster  |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests | Used for management operations. |
| C1.2 |            metal-ccm             |  Workload Cluster  |  HTTPS   | kube-apiserver |  Workload Cluster   | 443  |  x  |  x  |  x   |   x   | API Requests | Used for management operations. |
| C2.1 | cluster-api-provider-metal-stack | Management Cluster |  HTTPS   |   metal-api    | Metal Control Plane | 443  |  x  |  x  |  x   |       | API Requests | Used for management operations. |

## With Lightbits

In order to use Lightbits as a storage solution, the following communications are required by metal-stack components.

!!! info

    The following table might not be displayed in completeness. Scroll to the right to see all entries.

| No.  |     Component     |  Source Zone  | Protocol |  Destination   | Destination Zone  | Port |  C  |  I  | Auth | Trust |  Purpose   |              Notes              |
| :--: | :---------------: | :-----------: | :------: | :------------: | :---------------: | :--: | :-: | :-: | :--: | :---: | :--------: | :-----------------------------: |
| L1.1 | duros-controller  | Seed Cluster  |  HTTPS   |   duros-api    | Lightbits Cluster | 443  |  x  |  x  |  x   |   x   |  Storage   | Used for management operations. |
| L1.2 | duros-controller  | Seed Cluster  |  HTTPS   | kube-apiserver |   Shoot Cluster   | 443  |  x  |  x  |  x   |   x   | Kubernetes | Used for management operations. |
| L2.1 | lb-csi-controller | Shoot Cluster |  HTTPS   |   duros-api    | Lightbits Cluster | 443  |  x  |  x  |  x   |       |  Storage   | Used for management operations. |
| L2.2 | lb-csi-controller | Shoot Cluster |  HTTPS   | kube-apiserver |   Shoot Cluster   | 443  |  x  |  x  |  x   |   x   | Kubernetes | Used for management operations. |
| L3.1 |    lb-csi-node    | Shoot Cluster |   TCP    |   duros-api    | Lightbits Cluster | 4420 |  x  |  x  |  x   |       |  Storage   | Used for management operations. |
| L3.2 |    lb-csi-node    | Shoot Cluster |   TCP    |   duros-api    | Lightbits Cluster | 8009 |  x  |  x  |  x   |       |  Storage   | Used for management operations. |
