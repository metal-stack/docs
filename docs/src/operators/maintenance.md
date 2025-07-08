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

## Releases

Before upgrading your metal-stack installation, review the release notes carefully - they contain important information on required pre-upgrade actions and notable changes. These notes are currently shared via a dedicated Slack channel and are also available in the release on GitHub. Once you are prepared, you can deploy a new metal-stack version by updating the `metal_stack_release_version` variable in your Ansible configuration and trigger the corresponding deployment jobs in your CI.
metal-stack offers prebuilt system images for firewalls and worker machines, which can be downloaded from images.metal-stack.io. In offline or air-gapped setups, these images must either be synced into the partition-local [image-cache](https://github.com/metal-stack/metal-image-cache-sync) after they were added to the metal-api or be manually downloaded in advance and uploaded to your local S3-compatible storage. Ensure that the image paths and metadata are correctly maintained so the system can retrieve them during provisioning.
If you are using metal-stack in combination with Gardener, make sure to reconcile all shoot clusters after upgrading metal-stack to ensure they remain in a consistent and fully functional state.
metal-images for firewalls and worker nodes follow independent release cycles, typically driven by the need for security patches or system updates. When new images are made available, reconciling provisioned machines is necessary to apply them.
In a Gardener setup, image updates can be triggered by referencing the new image in the shoot spec.
Because all outbound traffic passes through the firewall node, this results in a short downtime of around 30 seconds. This interruption only occurs if the firewall image has actually changed. The process works as follows: a new firewall node is provisioned and configured in parallel with the existing one. Once setup is complete, traffic is switched over to the new node, and the old firewall is then decommissioned. This minimizes disruption while ensuring a seamless transition.
The worker nodes are rolled out one after the other and, if possible, the containers are redistributed to the machines that are still available. However, for stateful workloads like databases, temporary disruptions may occur during node restarts.

## Rollback

metal-stack employs forward-only database migrations (e.g., for RethinkDB), and each release undergoes thorough integration testing. However, rollback procedures are not included in test coverage. To maintain data integrity and system reliability, rolling back a full release is not supported and strongly discouraged. In the event of issues after an upgrade, it is possible to downgrade specific components rather than reverting the entire system.