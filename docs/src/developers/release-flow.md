# Releases and Updates

Releases and integration tests are published through our [release repository](https://github.com/metal-stack/releases). You can also find the [release notes](https://github.com/metal-stack/releases/releases) for this metal-stack version in there. The release notes contain information about new features, upgrade paths and bug fixes.

A release is created in the following way:

- Individual repository maintainers within the metal-stack Github Org can publish a release of their component.
- This release is automatically pushed to the `develop` branch of the release repository by the metal-robot.
- The push triggers a small release integration test through the mini-lab.
- To contribute components that are not directly part of the release vector, a pull request must be made against the `develop` branch of the release repository. Release maintainers may push directly to the `develop` branch.
- The release maintainers can `/freeze` the `develop` branch, effectively stopping the metal-robot from pushing component releases to this branch.
- The `develop` branch is tagged by a release maintainer with a `-rc.x` suffix to create a __release candidate__.
- The release candidate must pass a large integration test suite on a real environment, which is currently run by FI-TS. It tests the entire machine provisioning engine including the integration with Gardener, the deployment, metal-images and Kubernetes conformance tests.
- If the integration tests pass, the PR of the `develop` branch must be approved by at least two release maintainers.
- A release is created via Github releases, including all release notes, with a tag on the `main` branch.

If you want, you can sign up at our Slack channel where we are announcing every new release. Often, we provide additional information for metal-stack administrators and adopters at this place, too.
