## Update Policy

For new features and breaking changes we create a new minor release of metal-stack.
For every minor release we present excerpts of the changes in a corresponding blog article published on metal-stack.io.

It is not strictly necessary to cycle through the patch releases if you depend on the pure metal-stack components.
However, it is important to go through all the patch releases and apply all required actions from the release notes.
Therefore, we recommend to just install every patch release one by one in order to minimize possible problems during the update process.

In case you depend on the Gardener integration, especially when using metal-stack roles for deploying Gardener, we strongly recommend installing every patch release version.
We increment our Gardener dependency version by version following the Gardener update policy. Jumping versions may lead to severe problems with the installation and should only be done if you really know what you are doing.

!!! info

    If you use the Gardener integration of metal-stack do not skip any patch releases. You may skip patch releases if you depend on metal-stack only, but we recommend to just deploy every patch release one by one for the best possible upgrade experience.

## Rollback

Rollback in metal-stack is possible as long as no database schema migration has occurred between the releases. The system uses forward-only DB migrations (e.g. for RethinkDB), so if a schema change is involved, reverting the application requires also restoring the database to its previous state (pre-migration). This ensures data consistency and system stability.

If no database migration has taken place, the release version can simply be rolled back and redeployed. However, if a migration has occurred, the backup-restore-sidecar must be used to [manually](https://github.com/metal-stack/backup-restore-sidecar/blob/master/docs/manual_restore.md) restore the database from a backup created before the schema change.