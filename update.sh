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
    cd $path
    cd ..
    git clone $git_url --depth 1 --branch $ref --single-branch
    cd -
    ls -al
    find . -type f ! -name '*.md' -delete
    ls -al

}

echo "Getting release vector"
curl -Lo /tmp/release.yaml "https://raw.githubusercontent.com/metal-stack/releases/${version}/release.yaml"

echo "Updating external repositories"
update_repo "docs/src/external/csi-lvm" "https://github.com/metal-stack/csi-lvm.git" $(yq r /tmp/release.yaml 'docker-images.metal-stack.kubernetes.csi-lvm-controller.tag')