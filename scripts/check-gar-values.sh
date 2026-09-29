#!/usr/bin/env bash

# Verifies that charts/castai-umbrella/gar-values.yaml stays complete:
#
#  1. Render check: renders every umbrella profile with gar-values.yaml and
#     fails if any ghcr.io/castai/images reference survives in the output.
#  2. Values check: for every subchart values key that defaults to a
#     ghcr.io/castai/images string (including behind disabled features that
#     never render), fails unless gar-values.yaml overrides that exact key
#     in that profile section. Also flags ghcr images hardcoded in templates.
#
# ghcr.io/castai/live/* is intentionally out of scope (hardcoded castai-live
# hook images; see gar-values.yaml header).

set -o errexit
set -o nounset
set -o pipefail

for tool in helm yq git; do
    if ! command -v "$tool" >/dev/null; then
        echo "ERROR: required tool '$tool' is not installed." >&2
        exit 1
    fi
done

REPO_ROOT=$(git rev-parse --show-toplevel)
CHART_SRC="$REPO_ROOT/charts/castai-umbrella"
GAR_VALUES="$CHART_SRC/gar-values.yaml"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

CHART="$WORKDIR/castai-umbrella"
FAILED=0

function prepare_chart {
    echo "Preparing chart with dependencies in $WORKDIR..."
    cp -R "$CHART_SRC" "$CHART"

    # Isolated helm repo config: keeps the check hermetic and avoids resolution
    # problems when the user's config has several entries for the same repo URL.
    # Add every repository the profile charts declare dependencies on.
    export HELM_REPOSITORY_CONFIG="$WORKDIR/helm-repositories.yaml"
    export HELM_REPOSITORY_CACHE="$WORKDIR/helm-repository-cache"
    helm repo add castai-helm https://castai.github.io/helm-charts >/dev/null
    helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ >/dev/null

    # "update" rather than "build": automation bumps Chart.yaml pins without
    # regenerating Chart.lock, and Chart.yaml is the source of truth here.
    local profile
    for profile in "$CHART"/charts/*/; do
        if [[ -f "$profile/Chart.lock" ]]; then
            helm dependency update "$profile" >/dev/null
        fi
    done
    helm dependency update "$CHART" >/dev/null
}

function check_profile {
    local profile=$1
    shift

    local rendered leaks
    rendered=$(helm template gar-check "$CHART" \
        --set global.castai.apiKey=dummy \
        -f "$GAR_VALUES" \
        "$@")

    leaks=$(grep -oE 'ghcr\.io/castai/images[A-Za-z0-9._/:-]*' <<< "$rendered" | sort -u || true)
    if [[ -n "$leaks" ]]; then
        echo "FAIL: profile '$profile' still references ghcr.io/castai/images:" >&2
        sed 's/^/    /' <<< "$leaks" >&2
        FAILED=1
    else
        echo "OK: profile '$profile'"
    fi
}

function check_all_profiles {
    echo "Rendering all profiles with gar-values.yaml..."

    local tag
    for tag in readonly node-autoscaler workload-autoscaler full autoscaler-openshift; do
        check_profile "$tag" \
            --set global.castai.provider=eks \
            --set "tags.${tag}=true"
    done

    check_profile "kent" \
        --set global.castai.provider=eks \
        --set kent.enabled=true

    check_profile "autoscaler-anywhere" \
        --set global.castai.provider=anywhere \
        --set tags.autoscaler-anywhere=true \
        --set "autoscaler-anywhere.castai-agent.additionalEnv.ANYWHERE_CLUSTER_NAME=gar-check"
}

function ghcr_value_paths {
    # Prints "<values-key-path>|<default>" for every string value referencing
    # ghcr.io/castai/images in the given values.yaml.
    yq eval '.. | select(tag == "!!str" and test("ghcr\.io/castai/images")) | (path | join(".")) + "|" + .' "$1"
}

function check_values_coverage {
    # Structure-aware safety net for images the render checks cannot see
    # (defaults behind disabled features never render): for every subchart
    # values key that defaults to a ghcr.io/castai/images string, require
    # that gar-values.yaml overrides that exact key in that profile section.
    echo "Checking gar-values.yaml overrides every ghcr default, per profile section..."

    # Extract packaged subcharts so their values files are visible.
    local tgz
    find "$CHART" -name '*.tgz' | while read -r tgz; do
        tar -xzf "$tgz" -C "$(dirname "$tgz")"
    done

    local section_dir section component values_file key default expected gar_value count section_ok
    for section_dir in "$CHART"/charts/*/; do
        section=$(basename "$section_dir")
        count=0
        section_ok=1

        for values_file in "$section_dir"charts/*/values.yaml; do
            [[ -f "$values_file" ]] || continue
            component=$(basename "$(dirname "$values_file")")

            while IFS='|' read -r key default; do
                [[ -z "$key" ]] && continue
                count=$((count + 1))
                # Images are dual-published with identical paths, so the correct
                # GAR value is the ghcr default with the registry prefix swapped.
                expected="us-docker.pkg.dev/castai-hub/library${default#ghcr.io/castai/images}"
                gar_value=$(yq eval ".\"${section}\".\"${component}\".${key} // \"\"" "$GAR_VALUES")
                if [[ "$gar_value" != "$expected" ]]; then
                    echo "FAIL: section '$section', component '$component': '$key' must be '$expected' (found: '${gar_value:-<missing>}')." >&2
                    section_ok=0
                    FAILED=1
                fi
            done < <(ghcr_value_paths "$values_file")
        done

        if (( section_ok )); then
            echo "OK: section '$section' — ${count} ghcr default(s), all overridden."
        fi
    done

    # Hardcoded ghcr.io/castai/images literals in templates cannot be
    # overridden by any values file — flag them so they get fixed upstream.
    local hardcoded
    hardcoded=$(find "$CHART" -path '*/templates/*' \( -name '*.yaml' -o -name '*.tpl' \) \
        -exec grep -hoE 'ghcr\.io/castai/images[A-Za-z0-9._/:-]*' {} + 2>/dev/null | sort -u || true)
    if [[ -n "$hardcoded" ]]; then
        echo "FAIL: hardcoded ghcr.io/castai/images reference(s) in templates (not overridable by values):" >&2
        sed 's/^/    /' <<< "$hardcoded" >&2
        FAILED=1
    fi
}

function main {
    prepare_chart
    check_all_profiles
    check_values_coverage

    echo ""
    if (( FAILED )); then
        echo "RESULT: FAILED — fix charts/castai-umbrella/gar-values.yaml (see FAIL lines above)." >&2
        exit 1
    fi
    echo "RESULT: OK — gar-values.yaml is complete."
}

main
