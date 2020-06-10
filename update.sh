#!/usr/bin/env bash
set -exo pipefail

version=$1

function update_repo() {
    path=$1
    git_url=$2
    ref=$3
    echo "Updating repository ${path}"
    rm -rf $path
    mkdir -p $path
    pushd $path
    cd ..
    git clone $git_url --depth 1 --branch $ref --single-branch
    cd -
    rm -rf .git
    find . -type f ! -name '*.md' -delete
    popd
}

echo "Getting release vector"
curl -Lo /tmp/release.yaml "https://raw.githubusercontent.com/metal-stack/releases/${version}/release.yaml"

echo "Updating external repositories"
update_repo "docs/src/external/csi-lvm" "https://github.com/metal-stack/csi-lvm.git" $(yq r /tmp/release.yaml 'docker-images.metal-stack.kubernetes.csi-lvm-controller.tag')
update_repo "docs/src/external/mini-lab" "https://github.com/metal-stack/mini-lab.git" "master"
update_repo "docs/src/external/metalctl" "https://github.com/metal-stack/metalctl.git" $(yq r /tmp/release.yaml 'binaries.metal-stack.metalctl.version')
update_repo "docs/src/external/firewall-controller" "https://github.com/metal-stack/firewall-controller.git" "master"
