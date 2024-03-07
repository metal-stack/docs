# Releases and Updates

````@eval
using Docs

version = releaseVersion()

t = raw"""
Your are currently reading the documentation for the metal-stack `%s` release.
"""

markdownTemplate(t, version)
````

Releases and integration tests are published through our [release repository](https://github.com/metal-stack/releases). You can also find the [release notes](https://github.com/metal-stack/releases/releases) for this metal-stack version in there. The release notes contain information about new features, upgrade paths and bug fixes.

If you want, you can sign up at our Slack channel where we are announcing every new release. Often, we provide additional information for metal-stack administrators and adopters at this place, too.

## Update Policy

For new features and breaking changes we create a new minor release of metal-stack. For every minor release we present excerpts of the changes in a corresponding blog article published on metal-stack.io. It is not necessary to cycle through the patch releases if you depend on the pure metal-stack components.

In case you depend on the Gardener integration though, especially when using metal-stack roles for deploying Gardener, it may be necessary to cycle through the patch release versions of our metal-stack releases. We regularly increment our Gardener dependency version by version which is the recommended way to update Gardener.

!!! warning

    If you use the Gardener integration of metal-stack do not skip patch releases.
