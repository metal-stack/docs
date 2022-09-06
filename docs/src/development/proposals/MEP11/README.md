# Auditing of metal-stack resources

Currently no logs of the ownership of resources like machines, networks, ips and volumes are generated or kept. Though due to legal requirements data centers are required to keep track of this ownership over time to prevent liability issues when opening the platform for external users.

In this proposal we want to introduce a flexible and low-maintenance approach for auditing on top of [Meilisearch](https://www.meilisearch.com/).

## Overview

In general our auditing logs will be collected by a request interceptor or middleware. Every request and response will be processed and eventually logged to Meilisearch.
Meilisearch will be configured to regularly create chunks of the auditing logs. These finished chunks will be backed up to a S3 compatible storage with a read-only option enabled.

Of course sensitve data like session keys or passwords will be redacted before logging. We want to track relevant requests and responses. If auditing the request fails, the request itself will be aborted and will not be processed further. The requests and responses that will be audited will be annotated with a correlation id.

Transferring the meilisearch auditing data chunks to the S3 compatible storage will be done by a cronjob that is executed periodically.
To avoid data manipulation the S3 compatible storage will be configured to be read-only.

## Whitelisting

To reduce the amount of unnecessary logs we want to introduce a whitelist of resources and operations on those that should be logged.
Other requests will be passed directly to the next middleware or web service without any further processing.

As we are only interested in mutating endpoints, we ignore all GET requests.
The whitelist includes all `POST`, `PUT` and `DELETE` endpoints of the following services:

- Machines `v1/machine`, except:
  - `POST v1/machine/find`
  - `POST v1/machine/ipmi/find`
- Networks `v1/network`, except:
  - `POST v1/network/find`
- IPs `v1/ip`, except:
  - `POST v1/ip/find`
- GRPC Services and methods, that can create machines
  - `api.v1.BootService` method `Register`
  - `api.v1.EventService` method `Send`

## Affected components

- metal-api grpc server needs an auditing interceptor
- metal-api web server needs an auditing filter chain / middleware
- metal-api needs new command line arguments to configure the auditing
- mini-lab needs a Meilisearch instance
- mini-lab may need a local S3 compatible storage
- Consider auditing of volume allocations and freeings outside of metal-stack

## Alternatives considered

Instead of using Meilisearch we investigated using an immutable database like [immudb](https://immudb.io/). But immudb does not support chunking of data and due to its immutable nature, we will never be able to free up space of expired data. Even if we are legally allowed or required to delete data, we will not be able to do so with immudb.
