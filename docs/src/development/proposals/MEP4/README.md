# Multi-Tenancy for the metal-api

In the past we decided to treat the metal-api as a "low-level API", i.e. the API does not specifically deal with projects and tenants. A user with editor access can for example assign machines to every project he desires, he can see all the machines available and can control them.

Even though we always tried to reserve the possibility to sell metal-stack as a bare metal machine provider only, the ultimate objective to us has always been to create an API for Kubernetes clusters. Hence, we tried to keep the metal-api code base as small as possible and we added resource scoping to a "higher-level API", the cloud-api, a component that is not open-source. From there, a user would be able to only see his own clusters.

As time passed by, things changed: The metal-stack has become an open-source project and people are willing to adopt. Adopters don't have the cloud-api and they are interested in putting their own technologies on top of the metal-stack infrastructure. Introducing multi-tenancy to the metal-api is a serious chance of making our product better and more successful as it opens the door for:

- Becoming a "fully-featured" cloud provider with bare metal servers, networks and ip addresses treated as first-class citizens
- Letting untrusted / third-parties work with the API
- Narrowing down attack surfaces (through user roles and fine-grained permissions)
- Gaining performance through resource scopes
- Using the Gardener Dashboard (no need for individual metal-stack deployments per tenant)
- Discouraging people to implement their own scoping layers in front of the metal-stack

With these traits in place, wild ideas for the future come to mind:

- Having a public offering of metal-stack
- Allowing users to bring their own partitions (managed control plane)

## TBD

- There need to be permissions individual for a project

## User Scenarios

This is a collection of workflows from the perspective of a user that we want to provide after the implementation of this proposal.

### Project Creation

A regular user wants to create a project to later maintain multiple resources inside this project's workspace.

- The user has to login before he can interact with the API, either trough browser with name and password or with a project token:
  ```
  $ metalctl login
  ```
- A user is always associated with a tenant.
  ```
  $ metalctl whoami
  UserId: gerrit
  Email: gerrit@gerrit.gerrit
  Tenant: my-tenant
  Project:
  Issuer: https://dex.test.fi-ts.io/dex
  Roles:
    metal-stack-default-user
  Permissions:
    metal.v2.project.list
    metal.v2.project.get
    metal.v2.project.delete
    metal.v2.project.create
    metal.v2.project.update
    metal.v2.image.list
    metal.v2.image.get
    metal.v2.image.get-latest
    metal.v2.network.list
    metal.v2.network.get
    metal.v2.network.create-child
    metal.v2.network.delete-child
    metal.v2.network.update-child
    metal.v2.ip.list
    metal.v2.ip.get
    metal.v2.ip.create
    metal.v2.ip.delete
    metal.v2.ip.update
    metal.v2.machine.list
    metal.v2.machine.get
    metal.v2.machine.create
    metal.v2.machine.delete
    metal.v2.machine.update
  Resources:
    *
  Expires at Thu Jul 22 00:07:09 CEST 2021
  ```
- ```
  $ metalctl project create --name my-project
  ...
  ```
### Machine Creation

A regular user wants to create a machine resource.

Requirements: Project was created

- ```
  $ metalctl network ls
  ID                                      NAME                            PROJECT                                 PARTITION       NAT     SHARED  PREFIXES                        IPS
  internet                                Internet Network                                                                        true    false   212.34.83.0/27                   ●
  tenant-super-network-fra-equ01          Project Super Network                                                   fra-equ01       false   false   10.128.0.0/14                    ●
  underlay-fra-equ01                      Underlay Network                                                        fra-equ01       false   false   10.0.0.0/16                      ●
  ```
- `metalctl network allocate --partition fra-equ01 --name test --project <uui>`
- ```
  $ metalctl network ls
  ID                                      NAME                            PROJECT                                 PARTITION       NAT     SHARED  PREFIXES                        IPS
  internet                                Internet Network                                                                        true    false   212.34.83.0/27                   ●
  tenant-super-network-fra-equ01          Project Super Network                                                   fra-equ01       false   false   10.128.0.0/14                    ●
  └─╴08b9114b-ec47-4697-b402-a11421788dc6 test                            <uuid>                                  fra-equ01       false   false   10.128.64.0/22                   ●
  underlay-fra-equ01                      Underlay Network                                                        fra-equ01       false   false   10.0.0.0/16                      ●
  ```
- `metalctl machine ls` --> `[]`
- `metalctl machine create --networks internet,08b9114b-ec47-4697-b402-a11421788dc6 --project <uuid> --name test --hostname test --image ubuntu-20.04 --partition fra-equ01 --size c1-xlarge-x86`
- ```
  $ metalctl machine ls
  ❯ m machine ls
  ID                                                      LAST EVENT      WHEN    AGE             HOSTNAME                        PROJECT                                 SIZE                    IMAGE                           PARTITION
  00000000-0000-0000-0000-ac1f6b7befb2                    Phoned Home     20s     50d 4h          test                            <uuid>                                  c1-xlarge-x86           Ubuntu 20.04 20210415           fra-equ01
  ```

### Admin Machine Maintenance

Admins should be able to see "everything", even resources of tenant's regular users.

Reason why this user needs these priviliged rights is:

- Recover machines a tenant can't recover themselves (due to software bug)
- When a tenant leaves, resources have to be cleaned up
- Generally be able to observe the health of the entire installation
- Admins have set up the environment and are likely to have access to all the databases, such they were able to compromise the environment anyway

- ```
  $ metalctl machine ls
  ID                                                      LAST EVENT      WHEN    AGE             HOSTNAME                        PROJECT                                 SIZE                    IMAGE                           PARTITION
  00000000-0000-0000-0000-ac1f6b7befb2                    Phoned Home     4s      50d 4h          storage-2                       a0a4c959-b191-4b4d-8483-951ccc2ff3f1    c1-xlarge-x86           Centos 7 20210415               fra-equ01
  00000000-0000-0000-0000-0025905f207a                    Phoned Home     5s      103d 15m        shoot--phjjb...-firewall-0f96d  5820c4e7-fbd4-4e4b-a40b-2b83eb34bbe1    s1-large-x86            Firewall 2 Ubuntu 20210304      fra-equ01
  00000000-0000-0000-0000-ac1f6b7b77c8                    Phoned Home     5s      65d 8h          shoot--test-...-firewall-cf20f  00000000-0000-0000-0000-000000000001    c1-xlarge-x86           Firewall 2 Ubuntu 20210316      fra-equ01
  00000000-0000-0000-0000-ac1f6bd390a6    🚧              Waiting         59s                                                                                                                                                     fra-equ01
  00000000-0000-0000-0000-0025905f2032                    Phoned Home     4s      8d 1h           shoot--p5c7f...-firewall-c72be  5410a72d-14c1-424e-9896-71c7ee84d393    s1-large-x86            Firewall 2 Ubuntu 20210606      fra-equ01
  00000000-0000-0000-0000-ac1f6b7aeb90                    Phoned Home     4s      50d 4h          storage-0                       a0a4c959-b191-4b4d-8483-951ccc2ff3f1    c1-xlarge-x86           Centos 7 20210415               fra-equ01
  00000000-0000-0000-0000-ac1f6b7aeb76                    Phoned Home     4s      1d 16h          shoot--pskqm...p-0-576df-6f552  b5f26a3b-9a4d-48db-a6b3-d1dd4ac4abec    c1-xlarge-x86           Debian 10 20210719              fra-equ01
  00000000-0000-0000-0000-ac1f6b7d7efa                    Phoned Home     56s     105d 2h         shoot--phjjb...p-0-77fc5-sr5zn  5820c4e7-fbd4-4e4b-a40b-2b83eb34bbe1    s2-xlarge-x86           Debian 10 20210316              fra-equ01
  00000000-0000-0000-0000-ac1f6b7b77cc                    Phoned Home     4s      50d 4h          storage-1                       a0a4c959-b191-4b4d-8483-951ccc2ff3f1    c1-xlarge-x86           Centos 7 20210415               fra-equ01
  00000000-0000-0000-0000-ac1f6b7d7e32                    Phoned Home     4s      105d 2h         shoot--phjjb...p-0-77fc5-qldng  5820c4e7-fbd4-4e4b-a40b-2b83eb34bbe1    s2-xlarge-x86           Debian 10 20210316              fra-equ01
  11111111-2222-3333-4444-aabbccddeeff                    Waiting         6s                                                                                              s1-large-broken-x86                                     fra-equ01
  00000000-0000-0000-0000-ac1f6b7bed26                    Phoned Home     49s                                                                                             c1-xlarge-x86                                           fra-equ01
  00000000-0000-0000-0000-ac1f6b7b77e4                    Phoned Home     4s      1d 4h           shoot--p9sk4...-firewall-5b3b7  7b29e8ea-e4c8-4aaa-9e42-70dd39d20108    s1-large-x86            Firewall 2 Ubuntu 20210606      fra-equ01
  00000000-0000-0000-0000-ac1f6b7bed30                    Phoned Home     4s      105d 2h         shoot--test-...ker-5f9b5-ltk9g  00000000-0000-0000-0000-000000000001    c1-xlarge-x86           Ubuntu 20.04 20210316           fra-equ01
  00000000-0000-0000-0000-ac1f6bd3909c                    Phoned Home     4s      113d 31m        storage-firewall                a0a4c959-b191-4b4d-8483-951ccc2ff3f1    c1-large-x86            Firewall 2 Ubuntu 20210316      fra-equ01
  00000000-0000-0000-0000-ac1f6b7beb80                    Phoned Home     5s      1d 16h          shoot--p5c7f...p-0-5968d-gtk95  5410a72d-14c1-424e-9896-71c7ee84d393    c1-xlarge-x86           Debian 10 20210719              fra-equ01
  00000000-0000-0000-0000-ac1f6b7d7dc6                    Phoned Home     4s      105d 2h         shoot--phjjb...p-0-77fc5-k5wp6  5820c4e7-fbd4-4e4b-a40b-2b83eb34bbe1    s2-xlarge-x86           Debian 10 20210519              fra-equ01
  256b1c00-be6d-11e9-8000-3cecef22b288                    Phoned Home     5s      8d 1h           shoot--p5c7f...-firewall-9c9af  5410a72d-14c1-424e-9896-71c7ee84d393    n1-medium-x86           Firewall 2 Ubuntu 20210606      fra-equ01
  6f440a00-be4d-11e9-8000-3cecef22f91c                    Phoned Home     4s      6d 42m          shoot--pskqm...-firewall-44522  b5f26a3b-9a4d-48db-a6b3-d1dd4ac4abec    n1-medium-x86           Firewall 2 Ubuntu 20201214      fra-equ01
  00000000-0000-0000-0000-ac1f6bd39026    🚧              Waiting         56s                                                                                             c1-large-x86                                            fra-equ01
  00000000-0000-0000-0000-ac1f6bd390b2                    Phoned Home     4s      1d 14h          shoot--p5c7f...p-0-b5f87-pjpk2  5410a72d-14c1-424e-9896-71c7ee84d393    c1-large-x86            Debian 10 20210719              fra-equ01
  ```

### Custom Role Permissions

A user creates a custom role `ci-builder` and a project token for it:

- `metalctl role create --name ci-builder --permissions metal.v2.machine.get,metal.v2.machine.create,metal.v2.machine.delete`
- `metalctl project create-token --role ci-builder`

General question: Should there be a `masterdatactl` (something like an extension of `metalctl`) to maintain tenants, projects, quotas, users, roles and accounting details?


## Centralized vs. Decentralized User Management

- TBD (Dex, Keycloak, User Management)
- Initial user workflow
- Connect to external user management?

Advantages of Centralized:

- Much easier to adopt
- More developer-friendly
- Better to unit test

Advantages of Decentralized:

- Compliance (regulatory compliance)

### Global & User Scopes

The operators of the metal-stack should be able to provide "global" resources that users are able to use. This means, that users can view these resources, but they are not allowed to create, modify or delete them.

Where possible, users should be capable of creating their own resource entities.

Examples for "global" resources:

- Base Networks
- OS Images
- Firmware Updates
- ...

Examples for "user" resources:

- Child networks
- IPs
- Machines
- (OS Images, too?)
- ...

### Auditing

With the new API we also have the chance of introducing API auditing throughout the resources.

The auditing can be configured with different emitters, like:

- Rethinkdb (can be accessed through `metalctl audit ls`)
- Splunk
- Elasticsearch
- ...

And contain:

- User information (name, mail)
- Requested endpoint path
- Permissions
- OPA decision
- Status code

## Implementation

- Introducing API V2
- Introducing OPA
- Common filter queries for all resources

### API v2

We will need an API v2, which gives all components and users time to slowly change to the new API while maintaining the current functionality of the endpoints in the metal-api.

- Introduce new paths that allow decisions about access very early in the game (only from endpoint and the user permissions)
- Get rid off layer HMAC auth (can be replaced with project tokens)
- Move internal endpoints to gRPC (e.g. register machine), remove daisy-chained swagger client from metal-core
- Remove request wrapper structs from metal-go (https://github.com/metal-stack/metal-go/issues/33)

We can start working on this for every resource individually. The work will potentially turn into a new shared layer with common functionality between v1/v2 (e.g. code for machine creation) with the API-specific packages only becoming responsible for mapping requests.


### Resource Scoping

Just as implemented by the cloud-api, resource scoping needs to be added to almost every endpoint of the metal-api:

- Machines / Firewalls
  - A user should only be able to view machines / firewalls of the projects he has at least view access to
  - A user should only be able to create and destroy machines / firewalls for projects he has at least editor access to
    Provider-tenants with at least view access can additionally view machines which have no project assignments
    Provider-tenants with at least editor access can additionally allocate / reserve machines which have no project assignments
- Networks
  - A user should only be able to view networks of the projects he has at least view access to
  - A user should only be able to allocate networks of projects he has at least editor access to
  - A user should only be able to free networks assigned to projects he has at least editor access to
    Provider-tenants with at least view access can additionally view networks which have no project assignments
    Provider-tenants with at least editor access can additionally edit networks which have no project assignments
    Provider-tenants with at least admin access can additionally create or remove networks which have no project assignments
- IPs
  - A user should only be able to view ips of the projects he has at least view access to
  - A user should only be able to allocate ips in networks of projects he has at least editor access to
  - A user should only be able to free ips assigned to projects he has at least editor access to
- Projects
  - A logged in user is able to create projects when he has the permission to create projects
  - A user should only be able to view projects where he has at least view access to
  - A user should only be able to delete projects where he has admin access to
- Partitions / Images
  - Only provider-admin users can add, delete, update
  - All logged in users can view
- IPMI
  - Only provider-tenants can view machine IPMI data
- Endpoints for internal use
  - Should only be accessible with HMAC auth and the HMAC secrets are only known by components of the Metal Stack (mainly for communication between partition and control plane), never for third-party usage

For all of this we need enhance the database queries with a filter for projects that a user has access to. As we already use a client to the masterdata-api in the metal-api, we can extract project memberships of a logged in user from there.

### More permissions

We do not only need `kaas-...` permissions in the LDAP but also `maas-`. This way we can differentiate between permissions for the cloud-api and permissions for the metal-api.


## Migration

### Migrate Existing Gardener Projects to New API

- Do not point the secret bindings to a the shared provider secret in a partition. Create an individual provider-secret for the logged in tenant. The Gardener needs to use this tenant-specific provider secret to talk to the metal-api, do not give the Gardener HMAC access anymore.
- The provider secret partition mapping can be removed from the cloud-api config and from the deployment
