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

metal-stack employs forward-only database migrations (e.g., for RethinkDB), and each release undergoes thorough integration testing. However, rollback procedures are not included in test coverage. To maintain data integrity and system reliability, rolling back a full release is not supported and strongly discouraged. In the event of issues after an upgrade, it is possible to downgrade specific components rather than reverting the entire system.