#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PACKAGING_IMAGE="mcr.microsoft.com/container-package-app:latest"

main() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel)

    local changed
    changed=$(ct list-changed --config "$repo_root/ct.yaml")

    if [[ -z "$changed" ]]; then
        echo "No helm charts were updated, skipping.."
        exit 0
    fi

    local num_changed
    num_changed=$(wc -l <<< "$changed")

    if ((num_changed > 1)); then
        echo "This PR has changes to multiple charts. Please create individual PRs per chart." >&2
        exit 1
    fi

    # Strip charts directory.
    chartName="${changed##*/}"

    if [[ "$PR_TITLE" != "[$chartName] "* ]]; then
        echo "PR title must start with '[$chartName] '." >&2
        exit 1
    fi

    if [[ ! -d "./cnab-config/$chartName" ]]; then
        echo "CNAB bundle is not setup for $chartName, skipping.."
        exit 0
    fi

    # Update CNAB manifest.yaml to match Helm Chart version.
    local chartVersion
    chartVersion=$(yq '.version' < "./charts/$chartName/Chart.yaml")
    echo "Parsed Helm Chart version: $chartVersion"
    version="$chartVersion" yq -i '.version = env(version)' "./cnab-config/$chartName/manifest.yaml"

    # Parse image details from charts/<service>/values.yaml.
    local imageName
    local imageTag
    local imageRegistry
    local imageDigest
    local imageLocation
    # Strip castai- prefix to gen service name.
    imageName="${chartName##*-}"
    imageTag=$(yq '.appVersion' < "./charts/$chartName/Chart.yaml")
    imageRegistry=$(yq '.image.repository' < "./charts/$chartName/values.yaml")
    imageRegistry=$(echo "${imageRegistry%/$imageName}" | xargs)
    imageLocation="$imageRegistry/$imageName:$imageTag"
    # shellcheck disable=SC2086
    imageDigest=$(docker pull $imageLocation | grep  "Digest: " | sed 's|''Digest: ||g')

    # Update CNAB values.yaml with image details.
    digest="$imageDigest" yq -i '.global.azure.images.agent.digest = env(digest)' "./cnab-config/$chartName/values.yaml"
    name="$imageName" yq -i '.global.azure.images.agent.image = env(name)' "./cnab-config/$chartName/values.yaml"
    registry="$imageRegistry" yq -i '.global.azure.images.agent.registry = env(registry)' "./cnab-config/$chartName/values.yaml"

    # Create staging area to create CNAB directory structure.
    echo "Copying $chartName Helm chart to cpa-stage directory for packaging"
    mkdir .cpa-stage
    cp -R "./cnab-config/$chartName" "./.cpa-stage"
    cp -R "./charts/$chartName" "./.cpa-stage/$chartName/"
    # Merge CNAB specific configuration into values.yaml
    valuesPath="cnab-config/$chartName/values.yaml" yq -i '. *= load(env(valuesPath))' "./.cpa-stage/$chartName/$chartName/values.yaml"

    echo "Verifying CNAB package.."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD/.cpa-stage/$chartName":/data  "$PACKAGING_IMAGE" /bin/bash -c 'cd /data ; cpa verify --telemetryOptOut'
}

main

