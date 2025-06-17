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
- Fine-grained access permissions (every endpoint maps to a permission)
- Tenant scoping (disallow resource access to resources of other tenants)
- Project scoping (disallow resource access to resources of other projects)
- Access tokens in self-service for technical user access

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

- `metalstack.api.v2`: For end-user facing services
- `metalstack.admin.v2`: For operators and controllers which need access to unscoped entities

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

### API

The API server implements the services defined in the API and validates access to a method using OPA with the JWT tokens passed in the requests. The server is implemented using the connectrpc.com framework.

The API server implements the login flow through OIDC. After successful authentication, the API server derives user permissions from the OIDC provider and issues a new JWT token which is passed on to the user. The tokens including the permissions are stored in a redis compatible backend.

With these tokens, users can create Access Tokens for CI/CD or other use cases.

JWT Tokens can be revoked by admins and the user itself.

### API Server

Is put into a new github repo which implements the services defined in the `api` repository. It opens a `https` endpoints where the grpc (via connectrpc.com) and oidc servives are exposed.

### Migration of the Consumers

To allow consumers to migrate to the `v2` API gradually, both apis, the new and the old, are deployed in parallel. In the control-plane both apis are deployed side-by-side behind the ingress. `api.example.com` is forwarded to `metal-api` and `metal.example.com` is forwarded to the new `metal-apiserver`.

The api-server will talk to the existing metal-api during the process of migration services away to the new grpc api.

The migration process can be done in the following manner:

for each resource in the metal-api:

- create a new proto3 based definition in the `api` repo.
- implement the business logic per service in the new `metal-apiserver` without calling the metal-api.
- clients must be able to talk to `v1` and `v2` backend in parallel
- Deprecate the already migrated service in the swagger route to notify the client that this route should not be used anymore.
- identify all consumers of this resource and replace them to use the grpc instead of the rest api
- move the business logic incl. the backend calls to ipam, metal-db, masterdata-api, nsq for this resource from the metal-api to the `metal-apiserver`

We will migrate the rethinkdb backend implementation to a generic approach during this effort.

- Try to enhance the generic rethinkdb interface with `project` scoped methods.

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
| OS Image           |      | yes    |
| Machine            | yes  |        |
| Network (Base)     |      | yes    |
| Network (Children) | yes  |        |
| IP                 | yes  |        |
| Partition          |      | yes    |
| Project            | yes  |        |
| Project Token      | yes  |        |
| Size               |      | yes    |
| Switch             |      |        |
| Tenant             |      | yes    |

!!! info

    Example: A user can make use of the file system layouts provided by the admins, but can also create own layouts. Same applies for images. As soon as a user creates own resources, the user takes over the responsibility for the machine provisioning to succeed.
