#!/usr/bin/env bash
# Compares env vars defined in a component's Helm templates against the
# corresponding folded templates in the kubecast umbrella chart.
#
# Required env vars:
#   CHART_NAME     — e.g. castai-agent, castai-workload-autoscaler, castai-live
#   CHART_VERSION  — required only for castai-live (pulled from registry)
#
# Paths expected to exist at call time (set up by release-umbrella-rc.yml):
#   kubecast/      — clone of the kubecast repo (contains both services/ and castai-umbrella/)
#
# Writes markdown to stdout and, when GITHUB_OUTPUT is set, appends
#   drift_report<<DELIMITER / ... / DELIMITER
# to that file.

set -euo pipefail

CHART_NAME="${CHART_NAME:?CHART_NAME env var required}"
CHART_VERSION="${CHART_VERSION:-}"

COMP_TEMPLATES=""

if [ "$CHART_NAME" = "castai-live" ]; then
  if [ -z "$CHART_VERSION" ]; then
    echo "CHART_VERSION is required for castai-live" >&2
    exit 1
  fi
  # castai-live lives in a separate repo; pull its chart from the public registry.
  LIVE_UNTAR_DIR="/tmp/castai-live-chart"
  rm -rf "$LIVE_UNTAR_DIR"
  helm repo add castai-helm https://castai.github.io/helm-charts --force-update >/dev/null 2>&1
  helm pull castai-helm/castai-live \
    --version "$CHART_VERSION" \
    --untar \
    --untardir "$LIVE_UNTAR_DIR"
  COMP_TEMPLATES="${LIVE_UNTAR_DIR}/castai-live/templates"
else
  # Locate the chart inside kubecast/services/ by matching the chart name in Chart.yaml.
  CHART_YAML_PATH=$(find kubecast/services -name "Chart.yaml" -exec grep -l "^name: ${CHART_NAME}$" {} \; 2>/dev/null | head -1 || true)
  if [ -z "$CHART_YAML_PATH" ]; then
    cat <<MD
## Env-var drift: \`${CHART_NAME}\`

> Chart not found under \`kubecast/services/\` — skipping drift check.
> This component may be a subchart dependency only (e.g. castai-kentroller, castai-chart-upgrader).
MD
    exit 0
  fi
  COMP_TEMPLATES="$(dirname "$CHART_YAML_PATH")/templates"
fi

UMB_TEMPLATES="kubecast/castai-umbrella/chart/templates/${CHART_NAME}"

if [ ! -d "$COMP_TEMPLATES" ]; then
  cat <<MD
## Env-var drift: \`${CHART_NAME}\`

> Component templates not found at \`${COMP_TEMPLATES}\` — skipping drift check.
MD
  exit 0
fi

if [ ! -d "$UMB_TEMPLATES" ]; then
  cat <<MD
## Env-var drift: \`${CHART_NAME}\`

> Umbrella templates not found at \`${UMB_TEMPLATES}\` — skipping drift check.
> The umbrella may use a subchart for this component rather than flat templates.
MD
  exit 0
fi

extract_env_vars() {
  local dir="$1"
  grep -rh '^\s*- name:\s*[A-Z_]' "$dir" \
    | sed 's/.*- name:[[:space:]]*//' \
    | sed 's/[[:space:]]*$//' \
    | sort -u
}

COMP_VARS=$(extract_env_vars "$COMP_TEMPLATES")
UMB_VARS=$(extract_env_vars "$UMB_TEMPLATES")

COMP_ONLY=$(comm -23 \
  <(echo "$COMP_VARS") \
  <(echo "$UMB_VARS") \
  || true)

UMB_ONLY=$(comm -13 \
  <(echo "$COMP_VARS") \
  <(echo "$UMB_VARS") \
  || true)

build_report() {
  echo "## Env-var drift: \`${CHART_NAME}\`"
  echo ""
  if [ -z "$COMP_ONLY" ] && [ -z "$UMB_ONLY" ]; then
    echo "No drift detected — umbrella env vars match the component chart."
    return
  fi
  if [ -n "$COMP_ONLY" ]; then
    echo "### In component, missing from umbrella (need porting)"
    echo ""
    echo "| Env var |"
    echo "|---------|"
    while IFS= read -r var; do
      [ -z "$var" ] && continue
      echo "| \`${var}\` |"
    done <<< "$COMP_ONLY"
    echo ""
  else
    echo "No env vars missing from umbrella."
    echo ""
  fi
  if [ -n "$UMB_ONLY" ]; then
    echo "### In umbrella only (umbrella additions — informational)"
    echo ""
    echo "| Env var |"
    echo "|---------|"
    while IFS= read -r var; do
      [ -z "$var" ] && continue
      echo "| \`${var}\` |"
    done <<< "$UMB_ONLY"
  else
    echo "No umbrella-only env vars."
  fi
}

REPORT=$(build_report)
echo "$REPORT"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  DELIMITER="DRIFT_EOF_$(date +%s%N)"
  {
    echo "drift_report<<${DELIMITER}"
    echo "$REPORT"
    echo "${DELIMITER}"
  } >> "$GITHUB_OUTPUT"
fi
