# User Management

At the moment, metal-stack can more or less be seen as a low-level API that does not scope access based on projects and tenants.
Fine-grained access control with full multi-tenancy support is actively worked on in [MEP4](.././developers/proposals/MEP4/README.md).

Until then projects and tenants can be created, but have no effect on access control.

## Default Users

The current system provides three default users with their corresponding roles:

- **Metal-Admin** is an **Admin** can perform all actions.
- **Metal-Edit** has the **Edit** role and may create, edit and delete most resources.
- **Metal-Viewer** is a **Viewer** and may only view resources and may access machines.

## OIDC

Currently the only way to act as a different user than the default ones, is by using OIDC authentication. Here the OIDC provider decides which role the user has.

## Role Mapping

The following table shows which role is required to access the endpoints of the various services at a high level.
Only the minimum role required to access the group of endpoints is shown. For the more in-depth documentation of all endpoints, head over to the [API documentation](../references/apidocs.md).

| **Service**                     | **Group of Endpoints**          | **Minimum Role** |
| ------------------------------- | ------------------------------- | ---------------- |
| **audit-service**               | Reading audit traces            | Viewer           |
| **filesystem-service**          | Reading filesystem layouts      | Viewer           |
|                                 | Managing filesystem layouts     | Admin            |
| **firewall-service**            | Reading firewalls               | Viewer           |
|                                 | Allocating firewalls            | Editor           |
| **firmware-service**            | All endpoints                   | Admin            |
| **image-service**               | Reading images                  | Viewer           |
|                                 | Managing images                 | Admin            |
| **ip-service**                  | Reading IPs                     | Viewer           |
|                                 | Managing IPs                    | Editor           |
| **machine-service**             | Reading machines and issues     | Viewer           |
|                                 | Managing machines and issues    | Editor           |
|                                 | IPMI operations                 | Editor           |
|                                 | Updating, deleting machines     | Admin            |
|                                 | Updating firmware               | Admin            |
| **network-service**             | Reading networks                | Viewer           |
|                                 | Allocating and freeing networks | Editor           |
|                                 | Managing networks               | Admin            |
| **partition-service**           | Reading partitions              | Viewer           |
|                                 | Managing partitions             | Admin            |
| **project-service**             | Reading projects                | Viewer           |
|                                 | Managing projects               | Admin            |
| **size-service**                | Reading sizes                   | Viewer           |
|                                 | Managing reservations           | Editor           |
|                                 | Managing sizes                  | Admin            |
| **sizeimageconstraint-service** | Reading size image constraints  | Viewer           |
|                                 | Managing size image constraints | Admin            |
| **switch-service**              | Reading switches                | Viewer           |
|                                 | Managing switches               | Admin            |
| **tenant-service**              | Reading tenants                 | Viewer           |
|                                 | Managing tenants                | Admin            |
| **user-service**                | Getting user information        | Viewer           |
| **vpn-service**                 | Getting VPN auth key            | Admin            |
