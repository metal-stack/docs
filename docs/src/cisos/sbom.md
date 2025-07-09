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

## Identify CVEs

There are many tools that can help you to identify the CVEs with the help of an SBOM. Just to name one example, the [cve-bin-tool]() can be used to do this, which would look like this:

```plain
cve-bin-tool --sbom-file sbom.json --format json 

[09:57:06] INFO     cve_bin_tool - CVE Binary Tool v3.4                                                                                                                              cli.py:624
           INFO     cve_bin_tool - This product uses the NVD API but is not endorsed or certified by the NVD.                                                                        cli.py:625
           INFO     cve_bin_tool - For potentially faster NVD downloads, mirrors are available using -n json-mirror                                                                  cli.py:628
           INFO     cve_bin_tool.CVEDB - Using cached CVE data (<24h old). Use -u now to update immediately.                                                                       cvedb.py:320
           INFO     cve_bin_tool.CVEDB - There are 251234 CVE entries in the database                                                                                              cvedb.py:386
           INFO     cve_bin_tool.CVEDB - There are 205244 CVE entries from NVD in the database                                                                                     cvedb.py:388
           INFO     cve_bin_tool.CVEDB - There are 25495 CVE entries from GAD in the database                                                                                      cvedb.py:388
           INFO     cve_bin_tool.CVEDB - There are 20495 CVE entries from REDHAT in the database                                                                                   cvedb.py:388
           INFO     cve_bin_tool - CVE database contains CVEs from National Vulnerability Database (NVD), Open Source Vulnerability Database (OSV), Gitlab Advisory Database (GAD)   cli.py:915
                    and RedHat                                                                                                                                                                 
           INFO     cve_bin_tool - CVE database last updated on 01 July 2025 at 09:53:14                                                                                             cli.py:918
[09:57:13] INFO     cve_bin_tool - The number of products to process from SBOM - 116                                                                                                cli.py:1134
           INFO     cve_bin_tool - Overall CVE summary:                                                                                                                             cli.py:1181
           INFO     cve_bin_tool - There are 0 products with known CVEs detected                                                                                                    cli.py:1182
           INFO     cve_bin_tool.OutputEngine - JSON report stored                                                                                                                  __init__.py:878
