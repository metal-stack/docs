# Welcome to the metal-stack docs!

````@eval
using Docs

version = releaseVersion()

t = raw"""
Your are currently reading the documentation for the metal-stack `%s` release.
"""

markdownTemplate(t, version)
````

metal-stack is an open source software that provides an API for provisioning and managing physical servers in the data center. To categorize this product, we use the terms _Metal-as-a-Service (MaaS)_ or _bare metal cloud_.

From the perspective of a user, the metal-stack does not feel any different from working with a conventional cloud provider. Users manage their resources (machines, networks and ip addresses, etc.) by themselves, which effectively turns your data center into an elastic cloud infrastructure.

The major difference to other cloud providers is that compute power and data reside in your own data center.
