# SBOM

Every container image and binary that's part of metal-stack contains an _SBOM_ (Software Bill of Materials). It provides
a detailed inventory of components within container images and binaries, enabling you to manage vulnerabilities and
compliance effectively.

We decided to use [_SPDX_ (Software Package Data Exchange)](https://spdx.dev/), as it is among the most widely adopted
standards and is natively supported in Docker. Docker utilizes the
[in-toto SPDX format](https://github.com/in-toto/attestation/blob/main/spec/predicates/spdx.md), while binary-*SBOM*s
are created using [Syft](https://github.com/anchore/syft).

*SBOM*s are created as part of each repository's _GitHub Actions_ workflow utilizing
[Anchore SBOM Action](https://github.com/marketplace/actions/anchore-sbom-action) for binaries and
[Build and push Docker images](https://github.com/marketplace/actions/build-and-push-docker-images) for container
images.

## Download _SBOM_ of a container image

```bash
docker buildx imagetools inspect ghcr.io/metal-stack/<image name>:<tag> --format "{{ json .SBOM.SPDX }}" > sbom.json
```

For further info, refer to the
[Docker docs](https://docs.docker.com/build/metadata/attestations/sbom/#inspecting-sboms).

## Download _SBOM_ of a binary from the GitHub release

```bash
wget https://github.com/metal-stack/<repository name>/releases/latest/download/sbom.json
```

Please note, if more than one binary is released, e.g. for different platforms / architectures, you are required to
include this info in the _SBOM_ file name as well.

```bash
# This is an example using https://github.com/metal-stack/metalctl
wget https://github.com/metal-stack/metalctl/releases/latest/download/sbom-darwin-arm64.json
```
