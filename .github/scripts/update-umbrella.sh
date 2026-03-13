#!/usr/bin/env bash
# update-umbrella.sh <chart-name> <version> <repo-root>
# Updates umbrella subchart dependencies and bumps the umbrella chart version.
# Exits 0 in all cases; sets CHANGED=true/false in output.
set -euo pipefail

CHART_NAME="${1:?chart name required}"
VERSION="${2:?version required}"
REPO_ROOT="${3:-.}"

SUBCHART_FILES=(
  "${REPO_ROOT}/charts/castai-umbrella/charts/autoscaler/Chart.yaml"
  "${REPO_ROOT}/charts/castai-umbrella/charts/kent/Chart.yaml"
  "${REPO_ROOT}/charts/castai-umbrella/charts/readonly/Chart.yaml"
  "${REPO_ROOT}/charts/castai-umbrella/charts/node-autoscaler/Chart.yaml"
  "${REPO_ROOT}/charts/castai-umbrella/charts/workload-autoscaler/Chart.yaml"
  "${REPO_ROOT}/charts/castai-umbrella/charts/full/Chart.yaml"
)

CHANGED=false

for CHART_FILE in "${SUBCHART_FILES[@]}"; do
  if [ ! -f "$CHART_FILE" ]; then
    continue
  fi
  if yq ".dependencies[].name" "$CHART_FILE" | grep -qx "$CHART_NAME"; then
    CURRENT=$(yq ".dependencies[] | select(.name == \"$CHART_NAME\") | .version" "$CHART_FILE")
    if [ "$CURRENT" != "$VERSION" ]; then
      echo "Updating ${CHART_NAME} in ${CHART_FILE}: ${CURRENT} -> ${VERSION}"
      yq -i "(.dependencies[] | select(.name == \"$CHART_NAME\") | .version) = \"${VERSION}\"" "$CHART_FILE"
      CHANGED=true
    else
      echo "${CHART_NAME} in ${CHART_FILE} is already at ${VERSION}, skipping."
    fi
  fi
done

if [ "$CHANGED" == "false" ]; then
  echo "${CHART_NAME} is not a dependency of any umbrella subchart, skipping."
  exit 0
fi

UMBRELLA_CHART="${REPO_ROOT}/charts/castai-umbrella/Chart.yaml"
CURRENT=$(yq ".version" "$UMBRELLA_CHART")
MAJOR=$(echo "$CURRENT" | cut -d. -f1)
MINOR=$(echo "$CURRENT" | cut -d. -f2)
PATCH=$(echo "$CURRENT" | cut -d. -f3)
NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
yq -i ".version = \"${NEW_VERSION}\"" "$UMBRELLA_CHART"
echo "Bumped castai-umbrella version: ${CURRENT} -> ${NEW_VERSION}"

echo "CHANGED=true"
