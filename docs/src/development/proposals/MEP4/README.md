# Multi-Tenancy for the metal-api

!!! info

    This document is work in progress.

In the past we decided to treat the metal-api as a "low-level API", i.e. the API does not specifically deal with projects and tenants. A user with editor access can for example assign machines to every project he desires, he can see all the machines available and can control them. We tried to keep the metal-api code base as small as possible and we added resource scoping to a "higher-level APIs". From there, a user would be able to only see his own clusters and IP addresses.

As time passed metal-stack has become an open-source project and people are willing to adopt. Adopters who want to put their own technologies on top of the metal-stack infrastructure don't have those "higher-level APIs" that we implemented closed-source for our user base. So, external adopters most likely need to implement resource scoping on their own.

Introducing multi-tenancy to the metal-api is a serious chance of making our product better and more successful as it opens the door for:

- Becoming a "fully-featured" API
- Narrowing down attack surfaces and possibility of unintended resource modification produced by bugs or human errors
- Discouraging people to implement their own scoping layers in front of the metal-stack
- Gaining performance through resource scopes
- Letting untrusted / third-parties work with the API

## Table of Contents

```@contents
Pages = ["README.md"]
Depth = 5
```

## Requirements

These are some general requirements / higher objectives that MEP-4 has to fulfill.

- Should be able to run with mini-lab without requiring to setup complex auth backends (dex, LDAP, keycloak, ...)
  - Simple to start with, more complex options for production setups
- Should utilize auth mechanisms that we have already in place to best possible degree
- Fine-grained access permissions (every endpoint maps to a permission)
- Tenant scoping (disallow resource access to resources of other tenants)
- Project scoping (disallow resource access to resources of other projects)
- Access tokens in self-service for technical user access

Non-goals:

- Provide "tenant acts on-behalf" functionality (because we want only admins and these can act on-behalf)

## Implementation

We gathered a lot of knowledge while implementing a multi-tenancy-capable backend for metalstack.cloud. The goal is now to use the same technology and adopt that to the metal-api, this includes:

- gRPC in combination with connectrpc
- OPA for making auth decisions
- REST HTTP only for OIDC login flows

### API Definitions

The API definitions should be located on a separate Github repository separate from the server implementation. The proposed repository location is: https://github.com/metal-stack/api.

This repository contains the `proto3` specification of the exposed metal-stack api. This includes the messages, simple validations, services and the access permission to these services. The input parameters for the authorization in the backend are generated from the `proto3` annotations.

Client implementations for the most relevant languages (go, python) are generated automatically.

This api is divided into end-user and admin access at the top level. The proposed APIs are:

- `api.v2`: For end-user facing services
- `admin.v2`: For operators and controllers which need access to unscoped entities

The methods of the API can have different role scopes (and can be narrowed down further with fine-grained method permissions):

- `tenant`: Tenant-scoped methods, e.g. project creation (tenant needs to be provided in the request payload)
  - Available roles: VIEWER, EDITOR, OWNER
- `project`: Project-scoped methods, e.g. machine creation (tenant needs to be provided in the request payload)
  - Available roles: VIEWER, EDITOR, OWNER
- `admin` Admin-scoped methods, e.g. unscoped tenant list or switch register
  - Available roles: VIEWER, EDITOR

And has methods with different visibility scopes:

- `self`: Methods that only the logged in user can access, e.g. show permissions with the presented token
- `public`: Methods that do not require any specific authorization
- `private`: Methods that are not exposed

### API Server

The API server implements the services defined in the API and validates access to a method using OPA with the JWT tokens passed in the requests. The server is implemented using the connectrpc.com framework.

The API server implements the login flow through OIDC. After successful authentication, the API server derives user permissions from the OIDC provider and issues a new JWT token which is passed on to the user. The tokens including the permissions are stored in a redis compatible backend.

With these tokens, users can create Access Tokens for CI/CD or other use cases.

JWT Tokens can be revoked by admins and the user itself.

❓ Discuss: Should we create a new repository (https://github.com/metal-stack/api-server) or can we locate the new API in the existing metal-api project beneath `v2`?

### Migration of the Consumers

To allow consumers to migrate to the `v2` API gradually, both apis, the new and the old, are deployed in parallel. In the control-plane both apis are deployed side-by-side behind the ingress. `api.example.com` is forwarded to `metal-api` and `metal.example.com` is forwarded to the new `api-server`.

The the business logic of the metal-api must be maintained during the switch to the new `v2` api. To achieve this with it is required to extract the backend implementation, currently the `cmd/internal` package should be factored out to a consumable repository at `github.com/metal-stack/api-server/pkg/`. We will try to migrate the rethinkdb backend implementation to a generic approach during this effort.

There are a lot of consumers of metal-api, which need to be migrated:

- ansible
- firewall-controller
- firewall-controller-manager
- gardener-extension-auth
- gardener-extension-provider-metal
  - Do not point the secret bindings to a the shared provider secret in the seed anymore. Instead, use individual provider-secret containing project-scoped API access tokens in the Gardener project namespaces.
- machine-controller-manager-provider-metal
- metal-ccm
- metal-console
- metal-bmc
- metal-core
- metal-hammer
- metal-image-cache-sync
- metal-images
- metal-metrics-exporter
- metal-networker
- metalctl
- pixie

## User Scenarios

This section gathers a collection of workflows from the perspective of a user that we want to provide with the implementation of this proposal.

### Project Creation

A regular user wants to create a project to later maintain multiple resources inside this project's workspace.

Requirements: Tenant was created

- The user has to login before he can interact with the API. The login command will open a browser window as implemented already.

    ```bash
    metalctl login
    ```

- A user is always associated with a tenant.

    ```bash
    $ metalctl whoami
    UserId: gerrit
    Email: gerrit@gerrit.gerrit
    Tenant: metal-stack
    Issuer: https://metal.example.com
    ProjectRoles:
    TenantRoles:
        metal-stack-tenant-a: OWNER
    Expires at Thu Jul 22 00:07:09 CEST 2024
    ```

- The user can create a project.

    ```bash
    metalctl project create --name my-project
    ```

- The user has the option to direct all requests to a certain project (just like context switch)

    ```bash
    metalctl ctx update my-ctx --default-project 793bb6cd-8b46-479d-9209-0fedca428fe1
    ```

- The user automatically acquired the owner role for the project he created.

  ```bash
    $ metalctl whoami
    UserId: gerrit
    Email: gerrit@gerrit.gerrit
    Tenant: metal-stack
    Issuer: https://metal.example.com
    ProjectRoles:
        793bb6cd-8b46-479d-9209-0fedca428fe1: OWNER
    TenantRoles:
        metal-stack-tenant-a: OWNER
    Expires at Thu Jul 22 00:07:09 CEST 2024
  ```

### Machine Creation

A regular user wants to create a machine resource.

Requirements: Project was created, permissions are present

- The user can see networks that were provided by the admin.

  ```
  $ metalctl network ls
  ID                                      NAME                     PROJECT     PARTITION       NAT     SHARED  PREFIXES         IPS
  internet                                Internet Network                                     true    false   212.34.83.0/27    ●
  tenant-super-network-fra-equ01          Project Super Network                fra-equ01       false   false   10.128.0.0/14     ●
  underlay-fra-equ01                      Underlay Network                     fra-equ01       false   false   10.0.0.0/16       ●
  ```

- The user has to set the project scope first or provide `--project` flags for all commands.
  ```
  $ metalctl project set 793bb6cd-8b46-479d-9209-0fedca428fe1
  You are now acting on project 793bb6cd-8b46-479d-9209-0fedca428fe1.
  ```
- The user can create the child network required for machine allocation.
  ```
  $ metalctl network allocate --partition fra-equ01 --name test
  ```
- Now, the user sees his own child network.
  ```
  $ metalctl network ls
  ID                                      NAME                    PROJECT                                 PARTITION       NAT     SHARED  PREFIXES         IPS
  internet                                Internet Network                                                                true    false   212.34.83.0/27    ●
  tenant-super-network-fra-equ01          Project Super Network                                           fra-equ01       false   false   10.128.0.0/14     ●
  └─╴08b9114b-ec47-4697-b402-a11421788dc6 test                    793bb6cd-8b46-479d-9209-0fedca428fe1    fra-equ01       false   false   10.128.64.0/22    ●
  underlay-fra-equ01                      Underlay Network                                                fra-equ01       false   false   10.0.0.0/16       ●
  ```
- The user does not see any machines yet.
  ```
  $ metalctl machine ls
  ```
- The user can create a machine.
  ```
  $ metalctl machine create --networks internet,08b9114b-ec47-4697-b402-a11421788dc6 --name test --hostname test --image ubuntu-20.04 --partition fra-equ01 --size c1-xlarge-x86`
  ```
- The machine will now be provisioned.
  ```
  $ metalctl machine ls
  ID                                     LAST EVENT      WHEN    AGE      HOSTNAME   PROJECT                                 SIZE            IMAGE                   PARTITION
  00000000-0000-0000-0000-ac1f6b7befb2   Phoned Home     20s     50d 4h   test       793bb6cd-8b46-479d-9209-0fedca428fe1    c1-xlarge-x86   Ubuntu 20.04 20210415   fra-equ01
  ```

!!! warning

    A user **cannot** list all allocated machines for all projects. The user **must** always switch project context first and can only view the machines inside this project. Only admins can see all machines at once.

### Admin Machine Maintenance

Admins should be able to see "everything", even resources of tenant's regular users. The reasons why this user needs these privileged rights is:

1. Recover machines a tenant can't recover themselves (due to software bug)
1. When a tenant leaves, resources may need to be cleaned up
1. The admin should generally be able to observe the health of the entire installation
1. Admins have set up the environment and are likely to have access to all the databases, such they were able to compromise the environment anyway

- The user has permissions to create a project.

  ```bash
    $ metalctl whoami
    UserId: gerrit
    Email: gerrit@gerrit.gerrit
    Tenant: metal-stack
    Issuer: https://metal.example.com
    ProjectRoles:
        793bb6cd-8b46-479d-9209-0fedca428fe1: OWNER
    TenantRoles:
        metal-stack-tenant-a: OWNER
    Expires at Thu Jul 22 00:07:09 CEST 2024
  AdminRoles:
    *: OWNER
  ```

- The admin user can see all machines there are.

  ```bash
  $ metalctl admin machine ls
  ...
  ```

### Limited API Access Through Technical Users

A user creates a custom role `ci-builder` and a project token for it. A user cannot elevate his permissions, which needs to be prevented by the API.

- The user has permissions to create a role.
  ```
  $ metalctl show-permissions
  Project: 793bb6cd-8b46-479d-9209-0fedca428fe1
  Roles:
    metal-project-creator
    metal-project-owner
  Permissions:
    metal.v2.role.list
    metal.v2.role.get
    metal.v2.role.create
    metal.v2.role.update
    metal.v2.role.delete
    metal.v2.project.token-list
    metal.v2.project.token-get
    metal.v2.project.token-create
    metal.v2.project.token-revoke
    ...more typical user permissions...
  Resources:
    *
  ```
- A user can create a custom role and a role binding for the project. He can't elevate his permissions and can only create roles with permissions the user owns on this project.
  ```
  $ metalctl role create --name ci-builder --permissions metal.v2.machine.get,metal.v2.machine.create,metal.v2.machine.delete
  ```
- The user can create the project token.
  ```
  $ metalctl project token create --role ci-builder
  <token>
  ```
- This command created a role binding:
  ```
  $ metalctl rolebinding describe 131e10f0-509f-450f-99d4-3b793cc4db59
  {
    "id": "131e10f0-509f-450f-99d4-3b793cc4db59",
    "name": "project-token",
    "tenantid": "metal-stack",
    "projectid": "793bb6cd-8b46-479d-9209-0fedca428fe1",
    "roles": [
      {
        "id": "c3e24647-709e-44da-b551-cbfb1909e328",
        "name": "ci-builder",
        "projectid": "793bb6cd-8b46-479d-9209-0fedca428fe1",
        "permissions": [
          "metal.v2.machine.get",
          "metal.v2.machine.create",
          "metal.v2.machine.delete"
        ]
      }
    ],
    "userids": [],
    "projecttokens": ["19c92a80-f5ae-47be-973a-76e47894be8a"],
    "resources": ["*"],
    "oidcgroups: []
  }
  ```
- This token can now be used for login, too.
  ```
  $ metalctl login --project-token <token>
  ```
- The project token has restricted permissions.
  ```
  $ metalctl whoami
  UserId: gerrit
  Email: gerrit@gerrit.gerrit
  Tenant: metal-stack
  Issuer: https://dex.test.io/dex
  No expiration (project token 19c92a80-f5ae-47be-973a-76e47894be8a)

  $ metalctl show-permissions
  Project: 793bb6cd-8b46-479d-9209-0fedca428fe1
  Roles:
    ci-builder
  Permissions:
    metal.v2.machine.get
    metal.v2.machine.create
    metal.v2.machine.delete
  Resources:
    *
  ```

❓ Discuss: Should there be a `masterdatactl` (something like an extension of `metalctl`) to maintain tenants, projects, quotas, users, roles and annotations for accounting?

### Scopes for Resources

The admins / operators of the metal-stack should be able to provide _global_ resources that users are able to use along with their own resources. In particular, users can view and use _global_ resources, but they are not allowed to create, modify or delete them.

!!! info

    When a project ID field is empty on a resource, the resource is considered _global_.

Where possible, users should be capable of creating their own resource entities.

| Resource           | User | Global |
| :----------------- | :--- | :----- |
| File System Layout | yes  | yes    |
| Firewall           | yes  |        |
| Firmware           |      | yes    |
| OS Image           | yes  | yes    |
| Machine            | yes  |        |
| Network (Base)     |      | yes    |
| Network (Children) | yes  |        |
| IP                 | yes  |        |
| Partition          |      | yes    |
| Project            | yes  |        |
| Project Token      | yes  |        |
| Role               | yes  | yes    |
| Role Binding       | yes  | yes    |
| Size               |      | yes    |
| Switch             |      |        |
| Tenant             |      | yes    |

!!! info

    Example: A user can make use of the file system layouts provided by the admins, but can also create own layouts. Same applies for images. As soon as a user creates own resources, the user takes over the responsibility for the machine provisioning to succeed.
