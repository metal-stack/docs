#!/usr/bin/env bash
set -exo pipefail

version=$1

function update_repo() {
    path=$1
    git_url=$2
    ref=$3
    if [[ $ref == "latest" ]]; then ref=master; fi
    echo "Updating repository ${path}"
    rm -rf $path
    mkdir -p $path
    pushd $path
    cd ..
    git clone $git_url --depth 1 --branch $ref --single-branch
    cd -
    rm -rf .git
    find . -type f ! \( -name "*.md" -o -name "*.png" -o -name "*.svg" \) -delete
    popd

    cat << 'EOF' >> ${path}/README.md

## Page Tree

```@contents
Pages = vcat([[joinpath(root, file)[length(@__DIR__)+2:end] for file in files] for (root, dirs, files) in walkdir(@__DIR__)]...)
```
EOF
}

echo "Getting release vector"
curl -Lo /tmp/release.yaml "https://raw.githubusercontent.com/metal-stack/releases/${version}/release.yaml"

echo "Updating external repositories"
update_repo "docs/src/external/csi-driver-lvm" "https://github.com/metal-stack/csi-driver-lvm.git" master
update_repo "docs/src/external/mini-lab" "https://github.com/metal-stack/mini-lab.git" "$(yq e '.projects.metal-stack.mini-lab.version' /tmp/release.yaml)"
update_repo "docs/src/external/metalctl" "https://github.com/metal-stack/metalctl.git" "$(yq e '.binaries.metal-stack.metalctl.version' /tmp/release.yaml)"

# TODO: For next release enable:
# echo "Getting GEPM image vector"
# curl -Lo /tmp/gepm-images.yaml "https://raw.githubusercontent.com/metal-stack/gardener-extension-provider-metal/$(yq r /tmp/release.yaml 'docker-images.metal-stack.gardener.gardener-extension-provider-metal.tag')/charts/images.yaml"
# update_repo "docs/src/external/firewall-controller" "https://github.com/metal-stack/firewall-controller.git" $(yq r /tmp/gepm-images.yaml 'images.(name==firewall-controller).tag')

echo "Special handling"
# in metalctl/docs the generated do not start with a top-level heading (#) but with a sub-heading (##)
# (hard-coded in cobra)
# due to this reason the search results look very odd because the pages are indexed with the name "-"
sed -i 's/^##/#/g' docs/src/external/metalctl/docs/*
