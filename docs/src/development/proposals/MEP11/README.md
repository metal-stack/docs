# Auditing of metal-stack resources

Currently no logs of the ownership of resources like machines, networks, ips and volumes are generated or kept.Though due to legal requirements data centers are required to keep track of this ownership over time to prevent liability issues when opening the platform for external users.

In this proposal we want to introduce a flexible and low-maintenance approach for auditing on top of [Meilisearch](https://www.meilisearch.com/).

## Overview

In general our auditing logs will be collected by a request interceptor or middleware. Every request and response will be processed and eventually logged to Meilisearch.
Meilisearch will be configured to regularly create chunks of the auditing logs. These finished chunks will be backed up to a S3 compatible storage with a read-only option enabled.

Of course sensitve data like session keys or passwords will be redacted before logging.

Transferring the meilisearch auditing data chunks to the S3 compatible storage will be done by a cronjob that is executed periodically.
To avoid data manipulation the S3 compatible storage will be configured to be read-only.

## Whitelisting

To reduce the amount of unnecessary logs we want to introduce a whitelist of resources and operations on those that should be logged.
Other requests will be passed directly to the next middleware or web service without any further processing.

As we are only interested in mutating endpoints, we ignore all GET requests.
The whitelist includes the following endpoints:

- Machines `v1/machine`
  - `POST v1/machine/` update machine
  - `POST v1/machine/register` register machine, _if still present_
  - `POST v1/machine/allocate` allocate machine
  - `POST v1/machine/{id}/finalize-allocation` finalize allocation, _if still present_
  - `POST v1/machine/{id}/state` set machine state
  - `POST v1/machine/{id}/chassis-identify-led-state` set the state of a chassis identify LED, _if still present_
  - `DELETE v1/machine/{id}/free` free machine
  - `DELETE v1/machine/{id}` delete machine
  - `POST v1/machine/{id}/reinstall` reinstall machine
  - `POST v1/machine/{id}/abort-reinstall` aborts reinstall, _if still present_
  - `POST v1/machine/{id}/event` adds a provisioning event, _if still present_
  - `POST v1/machine/update-firmware/{id}` update firmware of machine
- Networks `v1/network`
  - `DELETE v1/network/{id}` delete network
  - `PUT v1/network/` create network
  - `POST v1/network/` update network
  - `POST v1/network/allocate` allocate network
  - `DELETE v1/network/free/{id}` free network
  - `POST v1/network/free/{id}` _deprecated_ free network
- IPs `v1/ip`
  - `DELETE v1/ip/free/{id}` free ip
  - `POST v1/ip/free/{id}` _deprecated_ free ip
  - `POST v1/ip/` update ip
  - `POST v1/ip/allocate` allocate ip
  - `POST v1/ip/allocate/{id}` allocate specific ip
- GRPC Services and methods, that can create machines
  - `api.v1.BootService` method `Register`
  - `api.v1.EventService` method `Send`

The following resources and operations will explicitly not be logged even though they are mutating the state of the system:

- Machines `v1/machine`
  - `POST v1/machine/{id}/power/on` power on machine
  - `POST v1/machine/{id}/power/off` power off machine
  - `POST v1/machine/{id}/power/reset` reset machine
  - `POST v1/machine/{id}/power/cycle` send power cycle to machine
  - `POST v1/machine/{id}/power/bios` boot machine into bios
  - `POST v1/machine/{id}/power/disk` boot machine from disk
  - `POST v1/machine/{id}/power/pxe` boot machine from pxe
  - `POST v1/machine/{id}/power/chassis-identify-led-on` turn on chassis identify LED
  - `POST v1/machine/{id}/power/chassis-identify-led-off` turn off chassis identify LED

## Affected components

- metal-api grpc server needs an auditing interceptor
- metal-api web server needs an auditing filter / middleware
- metal-api needs new command line arguments to configure the auditing
- mini-lab needs a Meilisearch instance
- mini-lab may need a local S3 compatible storage
- Consider auditing of volume allocations and freeings outside of metal-stack

## Alternatives considered

Instead of using Meilisearch we investigated using an immutable database like [immudb](https://immudb.io/). But immudb does not support chunking of data and due to its immutable nature, we will never be able to free up space of expired data. Even if we are legally allowed or required to delete data, we will not be able to do so with immudb.
