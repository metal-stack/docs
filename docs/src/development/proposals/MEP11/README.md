# Auditing of metal-stack resources

Currently no logs of the ownership of resources like machines, networks, ips and volumes are generated or kept. Though due to legal requirements data centers are required to keep track of this ownership over time to prevent liability issues when opening the platform for external users.

In this proposal we want to introduce a flexible and low-maintenance approach for auditing on top of [Meilisearch](https://www.meilisearch.com/).

## Overview

In general our auditing logs will be collected by a request interceptor or middleware. Every request and response will be processed and eventually logged to Meilisearch.
Meilisearch will be configured to regularly create chunks of the auditing logs. These finished chunks will be backed up to a S3 compatible storage with a read-only option enabled.

Of course sensitve data like session keys or passwords will be redacted before logging. We want to track relevant requests and responses. If auditing the request fails, the request itself will be aborted and will not be processed further. The requests and responses that will be audited will be annotated with a correlation id.

Transferring the meilisearch auditing data chunks to the S3 compatible storage will be done by a sidecar cronjob that is executed periodically.
To avoid data manipulation the S3 compatible storage will be configured to be read-only.

## Whitelisting

To reduce the amount of unnecessary logs we want to introduce a whitelist of resources and operations on those that should be logged.
Other requests will be passed directly to the next middleware or web service without any further processing.

As we are only interested in mutating endpoints, we ignore all `GET` requests.
The whitelist includes all `POST`, `PUT`, `PATCH` and `DELETE` endpoints of the HTTP middleware except for the following (non-manipulating) route suffixes:

  - `/find`
  - `/notify`
  - `/try` and `/match`
  - `/capacity`
  - `/from-hardware`

Regarding GRPC audit trails, they are not so interesting because only internal clients are using this API. However, we can log the trails of the `Boot` service, which can be interesting to revise the machine lifecycle.

## Chunking in Meilisearch

We want our data to be chunked in Meilisearch. To accomplish this, we rotate the index identifier on a scheduled basis. The index identifiers will be derived from the current date and time.

To keep things simple, we only support hourly, daily and monthly rotation. The eventually prefixed index names will only include relevant parts of date and time like `2021-01`, `2021-01-01` or `2021-01-01_13`.

The metal-api will only write to the current index and switches to the new index on rotation. The metal-api will never read or update data in any indices.

## Moving chunks to S3 compatible storage

As Meilisearch will be filled with data over time, we want to move completed chunks to a S3 compatible storage. This will be done by a sidecar cronjob that is executed periodically. Note that the periods of the index rotation and the cronjob execution don't have to match.

When the backup process gets started, it initiates a [Meilisearch dump](https://docs.meilisearch.com/learn/advanced/dumps.html) of the whole database across all indices. Once the returned task is finished, the dump must be copied from a Meilisearch volume to the S3 compatible storage. After a successful copy, the dump can be deleted.

Now we want to remove all indices from Meilisearch, except the most recent one. For this, we [get all indices](https://docs.meilisearch.com/reference/api/indexes.html#list-all-indexes), sort them and [delete each index](https://docs.meilisearch.com/reference/api/indexes.html#delete-an-index) except the most recent one to avoid data loss.

For the actual implementation, we can build upon [backup-restore-sidecar](https://github.com/metal-stack/backup-restore-sidecar). But due to the index rotation and the fact, that older indices need to be deleted, this probably does not fit into the mentioned sidecar.

## S3 compatible storage

The dumps of chunks should automatically deleted after a certain amount of time, once we are either no longer allowed or required to keep them.
The default retention time will be 6 months. Ideally already uploaded chunks should be read-only to prevent data manipulation.

A candidate for the S3 compatible storage is Google Cloud Storage, which allows to configure automatic expiration of objects through a [lifecycle rule](https://cloud.google.com/storage/docs/managing-lifecycles?hl=en#storage-set-lifecycle-config-go).

## Affected components

- metal-api grpc server needs an auditing interceptor
- metal-api web server needs an auditing filter chain / middleware
- metal-api needs new command line arguments to configure the auditing
- mini-lab needs a Meilisearch instance
- mini-lab may need a local S3 compatible storage
- we need a sidecar to implement the backup to S3 compatible storage
- Consider auditing of volume allocations and freeings outside of metal-stack

## Alternatives considered

Instead of using Meilisearch we investigated using an immutable database like [immudb](https://immudb.io/). But immudb does not support chunking of data and due to its immutable nature, we will never be able to free up space of expired data. Even if we are legally allowed or required to delete data, we will not be able to do so with immudb.

In another variant of the Meilisearch approach the metal-api would also be responsible for copying chunks to the S3 compatible storage and deleting old indices. But separating the concerns allows completely different implementations for every deployment stage.
