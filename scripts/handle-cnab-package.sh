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
        exit 0
    fi

    local num_changed
    num_changed=$(wc -l <<< "$changed")

    if ((num_changed > 1)); then
        echo "This PR has changes to multiple charts. Please create individual PRs per chart." >&2
        exit 1
    fi

    # Strip charts directory.
    changed="${changed##*/}"

    if [[ "$CNAB_ACTION" != "VERIFY" && "$CNAB_ACTION" != "RELEASE" ]]; then
        echo "CNAB_ACTION must be one of: [VERIFY, RELEASE]."
        exit 1
    fi

    if [[ "$PR_TITLE" != "[$changed] "* ]]; then
        echo "PR title must start with '[$changed] '." >&2
        exit 1
    fi

    if [[ ! -d "./cnab-config/$changed" ]]; then
        echo "CNAB bundle is not setup for $changed service, skipping.."
        exit 0
    fi

    # Update CNAB manifest.yaml to match Helm Chart version.
    local chartVersion
    chartVersion=$(grep "version: " "$PWD/charts/$changed/Chart.yaml" | sed 's|version: ||g')
    echo "Parsed Helm Chart version: $chartVersion"
    sed -i "s|<chartVersion>|$chartVersion|g" "$PWD/cnab-config/$changed/manifest.yaml"

    # Parse image details from charts/<service>/values.yaml.
    local imageName
    local imageTag
    local imageRegistry
    local imageDigest
    local imageLocation
    # Strip castai- prefix to gen service name.
    imageName="${changed##*-}"
    imageTag=$(grep "appVersion: " "$PWD/charts/$changed/Chart.yaml" | sed 's|appVersion: ||g' | sed 's|"||g')
    imageRegistry=$(grep "repository: " "$PWD/charts/$changed/values.yaml" | sed 's|repository: ||g')
    imageRegistry=$(echo "${imageRegistry%/$imageName}" | xargs)
    imageLocation="$imageRegistry/$imageName:$imageTag"
    # shellcheck disable=SC2086
    imageDigest=$(docker pull $imageLocation | grep  "Digest: " | sed 's|''Digest: ||g')

    # Update CNAB values.yaml with image details.
    sed -i "s|<imageDigest>|$imageDigest|g" "$PWD/cnab-config/$changed/values.yaml"
    sed -i "s|<imageName>|$imageName|g" "$PWD/cnab-config/$changed/values.yaml"
    sed -i "s|<imageRegistry>|$imageRegistry|g" "$PWD/cnab-config/$changed/values.yaml"

    # Copy Helm Chart folder to CNAB directory and replace Chart values.yaml with CNAB values.yaml.
    echo "Copying $changed Helm chart to CNAB directory for packaging"
    PWD=$(pwd)
    cp -R "$PWD/charts/$changed" "$PWD/cnab-config/$changed/"
    mv "$PWD/cnab-config/$changed/values.yaml" "$PWD/cnab-config/$changed/$changed/values.yaml"

    if [[ "$CNAB_ACTION" == "VERIFY" ]]; then
      echo "Verifying CNAB package.."
      docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD/cnab-config/$changed":/data  mcr.microsoft.com/container-package-app:latest /bin/bash -c 'cd /data ; cpa verify --telemetryOptOut'
    fi

    if [[ "$CNAB_ACTION" == "RELEASE" ]]; then
      echo "Releasing CNAB package.."
      az login --service-principal -u "$AZURE_K8S_APP_MARKETPLACE_SP_ID" -p "$AZURE_K8S_APP_MARKETPLACE_SP_SECRET" --tenant "$AZURE_K8S_APP_MARKETPLACE_TENANT_ID" -o none
      TOKEN=$(az acr login --name "$AZURE_K8S_APP_MARKETPLACE_REGISTRY_NAME" --expose-token --output tsv --query accessToken)
      docker run --env TOKEN="$TOKEN" --env REGISTRY="$AZURE_K8S_APP_MARKETPLACE_REGISTRY_NAME" --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD/cnab-config/$changed":/data "$PACKAGING_IMAGE" /bin/bash -c 'cd /data ; docker login -p $TOKEN "$REGISTRY" --username 00000000-0000-0000-0000-000000000000; cpa buildbundle --telemetryOptOut'
    fi
}

main

