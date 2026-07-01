#!/usr/bin/env bash
# Detects structural drift between a component's Helm templates and the
# corresponding copied templates in the kubecast umbrella chart.
#
# STRATEGY (since 2026-07):
#   Instead of sending every template file to the AI on every release, we
#   diff the component between its previous and current release tags first.
#   - If only README / Chart.yaml-version-only / non-template files changed,
#     we emit "no template changes" and skip the AI call entirely.
#   - If template files DID change, we send the AI a unified diff per changed
#     file together with the current umbrella file, and ask whether the
#     umbrella reflects the component-side change.
#
# Required env vars:
#   CHART_NAME        — e.g. castai-agent, castai-pod-pinner, castai-live
#   CHART_VERSION     — e.g. 0.35.103 (used to assemble the current tag)
#   KIMCHI_API_KEY    — Kimchi Inference API key
#   GITLAB_TOKEN      — required only for castai-live (to clone gitlab.com/castai/*)
#
# Paths expected to exist at call time (created by release-umbrella-rc.yml):
#   helm-charts/      — full clone of helm-charts at the release tag (fetch-depth:0)
#   kubecast/         — full clone of the kubecast repo (no --depth)
#   For castai-live the script clones gitlab.com/castai/* itself.
#
# Writes markdown to stdout and, when GITHUB_OUTPUT is set, appends:
#   drift_report<<DELIMITER / ... / DELIMITER

set -euo pipefail

CHART_NAME="${CHART_NAME:?CHART_NAME env var required}"
CHART_VERSION="${CHART_VERSION:?CHART_VERSION env var required}"
KIMCHI_API_KEY="${KIMCHI_API_KEY:?KIMCHI_API_KEY env var required}"

KIMCHI_API_URL="https://llm.kimchi.dev/openai/v1/chat/completions"
KIMCHI_MODEL="minimax-m3"

# ── Component → (repo clone dir, component path, tag prefix) map ──────────────
#
# tag_prefix is the literal string we prepend to the version when building the
# current tag and the glob used to list previous tags. Concretely:
#   current_tag = <tag_prefix><CHART_VERSION>
#
# Repos:
#   "helm-charts" — local checkout at ./helm-charts (full history)
#   "kubecast"    — local clone at ./kubecast (full history)
#   "clm"         — cloned on demand into /tmp/castai-live-source (full history)
#
# Components NOT listed here are not supported by the diff-based drift check
# and will fall through to a "component not configured" skip.

REPO_CLONE_DIR=""
COMPONENT_PATH=""
TAG_PREFIX=""
CURRENT_TAG=""
COMP_TEMPLATES=""
COMP_DEPS_DIR=""

configure_component() {
  case "$CHART_NAME" in
    castai-evictor)
      REPO_CLONE_DIR="helm-charts"
      COMPONENT_PATH="charts/castai-evictor"
      TAG_PREFIX="castai-evictor-"
      ;;
    castai-chart-upgrader)
      REPO_CLONE_DIR="helm-charts"
      COMPONENT_PATH="charts/castai-chart-upgrader"
      TAG_PREFIX="castai-chart-upgrader-"
      ;;
    castai-agent)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/castai-agent/chart"
      TAG_PREFIX="castai-agent/v"
      ;;
    castai-pod-pinner)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/castai-pod-pinner/chart"
      TAG_PREFIX="castai-pod-pinner/v"
      ;;
    castai-cluster-controller)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/cluster-controller/charts/castai-cluster-controller"
      TAG_PREFIX="cluster-controller/v"
      ;;
    castai-kvisor)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/kvisor/chart"
      TAG_PREFIX="kvisor/v"
      ;;
    castai-pod-mutator)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/pod-mutator/chart"
      TAG_PREFIX="pod-mutator/v"
      ;;
    castai-spot-handler)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/spot-handler/charts/castai-spot-handler"
      TAG_PREFIX="spot-handler/v"
      ;;
    castai-workload-autoscaler)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/workload-autoscaler/charts/castai-workload-autoscaler"
      TAG_PREFIX="workload-autoscaler/v"
      ;;
    castai-workload-autoscaler-exporter)
      REPO_CLONE_DIR="kubecast"
      COMPONENT_PATH="services/workload-autoscaler/charts/castai-workload-autoscaler-exporter"
      TAG_PREFIX="workload-autoscaler/v"
      ;;
    castai-live)
      REPO_CLONE_DIR="clm"
      COMPONENT_PATH="helm"
      TAG_PREFIX="v"
      ;;
    *)
      return 1
      ;;
  esac
  CURRENT_TAG="${TAG_PREFIX}${CHART_VERSION}"
  return 0
}

if ! configure_component; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> Component is not configured for the diff-based drift check — skipping.
> Add it to \`configure_component\` in \`.github/scripts/check-umbrella-drift.sh\` to enable.
MD
  exit 0
fi

# ── Special handling for castai-live (clone clm with full history) ────────────

if [ "$CHART_NAME" = "castai-live" ]; then
  GITLAB_TOKEN="${GITLAB_TOKEN:?GITLAB_TOKEN env var required for castai-live}"
  LIVE_CLONE_DIR="/tmp/castai-live-source"
  rm -rf "$LIVE_CLONE_DIR"
  git clone \
    "https://oauth2:${GITLAB_TOKEN}@gitlab.com/castai/live/clm.git" \
    "$LIVE_CLONE_DIR"
  # Reroute REPO_CLONE_DIR to the actual checkout path.
  REPO_CLONE_DIR="$LIVE_CLONE_DIR"
  # Check out the release tag in a detached-head state so on-disk file reads
  # (used by the umbrella-file matcher) reflect the released code.
  git -C "$REPO_CLONE_DIR" checkout -q "$CURRENT_TAG"
  COMP_TEMPLATES="${REPO_CLONE_DIR}/helm/templates"
  COMP_DEPS_DIR="${REPO_CLONE_DIR}/helm/dependencies"
else
  COMP_TEMPLATES="${REPO_CLONE_DIR}/${COMPONENT_PATH}/templates"
fi

UMB_TEMPLATES="kubecast/castai-umbrella/chart/templates/${CHART_NAME}"

# Sanity-check clone exists.
if [ ! -d "$REPO_CLONE_DIR/.git" ]; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> Expected clone at \`${REPO_CLONE_DIR}\` not found — skipping drift check.
MD
  exit 0
fi

if [ ! -d "$UMB_TEMPLATES" ]; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> Umbrella templates not found at \`${UMB_TEMPLATES}\` — skipping drift check.
> The umbrella may use a subchart for this component rather than flat templates.
MD
  exit 0
fi

# ── Verify current tag exists in the clone ────────────────────────────────────

if ! git -C "$REPO_CLONE_DIR" rev-parse --verify --quiet "refs/tags/${CURRENT_TAG}" >/dev/null; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> Current release tag \`${CURRENT_TAG}\` not found in \`${REPO_CLONE_DIR}\` — skipping drift check.
> The clone may be shallow or the tag may not have been pushed yet.
MD
  exit 0
fi

# ── Find the previous tag for this component ──────────────────────────────────
# We list every tag matching the prefix, version-sort descending, and pick the
# entry immediately following the current tag. Using --sort=-v:refname keeps
# semver ordering correct even when point releases land out of order.

# Match `<prefix><digit>...` only — a bare `${TAG_PREFIX}*` glob would also
# match sibling components whose name extends ours (e.g. `castai-evictor-*`
# would match `castai-evictor-ext-0.5.0`).
TAG_GLOB="${TAG_PREFIX}[0-9]*"

PREV_TAG=$(git -C "$REPO_CLONE_DIR" tag -l "$TAG_GLOB" --sort=-v:refname \
  | awk -v cur="$CURRENT_TAG" '
      $0 == cur { found = 1; next }
      found     { print; exit }
    ')

if [ -z "$PREV_TAG" ]; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> ℹ️ First release of this component (no prior tag matching \`${TAG_GLOB}\` before \`${CURRENT_TAG}\`) — AI drift check skipped.
MD
  exit 0
fi

echo "DEBUG: diffing ${PREV_TAG} → ${CURRENT_TAG} for ${COMPONENT_PATH}" >&2

# ── Classify changed files ────────────────────────────────────────────────────
#
# Rules (per the agreed plan):
#   - README* (case-insensitive)           → ignored
#   - Chart.yaml with ONLY version/         → ignored
#     appVersion lines changed
#   - Chart.yaml with any other change      → template-relevant
#   - ci/ test-values files                 → ignored
#   - Anything outside templates/ and not   → ignored
#     covered above
#   - Anything inside templates/ (incl.     → template-relevant
#     _helpers.tpl etc.)

CHANGED_FILES=()
IGNORED_FILES=()
TEMPLATE_FILES=()

# git diff prints paths relative to the repo root; we filter by COMPONENT_PATH.
# Avoid `mapfile` for portability with bash 3.2 (macOS default).
while IFS= read -r line; do
  [ -n "$line" ] && CHANGED_FILES+=("$line")
done < <(
  git -C "$REPO_CLONE_DIR" diff --name-only "${PREV_TAG}..${CURRENT_TAG}" -- "${COMPONENT_PATH}"
)

# Is a Chart.yaml change limited to version: / appVersion:?
# Returns 0 if yes (ignorable), 1 if no (template-relevant).
chart_yaml_only_version_changed() {
  local rel_path="$1"
  local prev_content cur_content
  prev_content=$(git -C "$REPO_CLONE_DIR" show "${PREV_TAG}:${rel_path}" 2>/dev/null || true)
  cur_content=$(git -C "$REPO_CLONE_DIR" show "${CURRENT_TAG}:${rel_path}" 2>/dev/null || true)
  # If either side is missing, treat as template-relevant (add/remove).
  if [ -z "$prev_content" ] || [ -z "$cur_content" ]; then
    return 1
  fi
  # Strip version: / appVersion: lines from both sides and compare.
  local prev_stripped cur_stripped
  prev_stripped=$(printf '%s\n' "$prev_content" | grep -Ev '^[[:space:]]*(version|appVersion)[[:space:]]*:')
  cur_stripped=$(printf '%s\n' "$cur_content"  | grep -Ev '^[[:space:]]*(version|appVersion)[[:space:]]*:')
  [ "$prev_stripped" = "$cur_stripped" ]
}

for f in "${CHANGED_FILES[@]}"; do
  # Path relative to COMPONENT_PATH (e.g. "templates/deployment.yaml").
  rel="${f#${COMPONENT_PATH}/}"
  base=$(basename "$rel")

  # README* (case-insensitive)
  base_lower=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')
  if [[ "$base_lower" == readme* ]]; then
    IGNORED_FILES+=("$f (README)")
    continue
  fi

  # ci/ directory
  if [[ "$rel" == ci/* ]]; then
    IGNORED_FILES+=("$f (ci/)")
    continue
  fi

  # Chart.yaml — ignore if only version/appVersion changed
  if [ "$base" = "Chart.yaml" ]; then
    if chart_yaml_only_version_changed "$f"; then
      IGNORED_FILES+=("$f (Chart.yaml version-only)")
      continue
    fi
    TEMPLATE_FILES+=("$f")
    continue
  fi

  # Anything inside templates/ is template-relevant
  if [[ "$rel" == templates/* ]]; then
    TEMPLATE_FILES+=("$f")
    continue
  fi

  # For castai-live, dependencies/ subtree is also template-relevant
  # (it's flattened into umbrella files like aws-vpc-cni.yaml, crd.yaml).
  if [ "$CHART_NAME" = "castai-live" ] && [[ "$rel" == dependencies/* ]]; then
    TEMPLATE_FILES+=("$f")
    continue
  fi

  # Everything else: outside templates/, not Chart.yaml/README/ci → ignored.
  IGNORED_FILES+=("$f (outside templates/)")
done

# ── If nothing template-relevant changed, emit the short-circuit message ─────

if [ ${#TEMPLATE_FILES[@]} -eq 0 ]; then
  REPORT="## Template drift: \`${CHART_NAME}\`

✅ No template changes between \`${PREV_TAG}\` and \`${CURRENT_TAG}\` — AI drift check skipped."

  echo "$REPORT"

  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    DELIMITER="DRIFT_EOF_$(date +%s%N)"
    {
      echo "drift_report<<${DELIMITER}"
      echo "$REPORT"
      echo "${DELIMITER}"
    } >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi

# ── Kimchi API call helper (unchanged from previous revision) ─────────────────

call_kimchi() {
  local prompt="$1"
  local prompt_json

  if command -v python3 &>/dev/null; then
    prompt_json=$(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$prompt")
  else
    prompt_json=$(printf '%s' "$prompt" \
      | sed 's/\\/\\\\/g; s/"/\\"/g' \
      | awk '{printf "%s\\n", $0}' \
      | sed 's/\\n$//' \
      | sed 's/\t/\\t/g')
    prompt_json="\"${prompt_json}\""
  fi

  local req_file
  req_file=$(mktemp /tmp/kimchi-request-XXXXXX.json)
  cat > "$req_file" <<EOF
{
  "model": "${KIMCHI_MODEL}",
  "max_tokens": 4096,
  "messages": [{ "role": "user", "content": ${prompt_json} }]
}
EOF

  echo "DEBUG: request size: $(wc -c < "$req_file") bytes" >&2

  local response
  response=$(curl -s \
    -w "\n__HTTP_STATUS__:%{http_code}" \
    -X POST "$KIMCHI_API_URL" \
    -H "Authorization: Bearer ${KIMCHI_API_KEY}" \
    -H "Content-Type: application/json" \
    --data-binary "@${req_file}" 2>&1)
  local exit_code=$?
  rm -f "$req_file"

  local status
  status=$(echo "$response" | grep -o '__HTTP_STATUS__:[0-9]*' | cut -d: -f2)
  local body
  body=$(echo "$response" | sed 's/__HTTP_STATUS__:[0-9]*$//')

  echo "DEBUG: HTTP_STATUS: ${status}" >&2

  if [ $exit_code -ne 0 ] || [ "${status:-0}" -lt 200 ] || [ "${status:-0}" -ge 300 ]; then
    echo "> ❌ Kimchi API call failed (HTTP ${status:-unknown}): ${body}" >&2
    return 1
  fi

  if command -v python3 &>/dev/null; then
    python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d['choices'][0]['message']['content'])" <<< "$body"
  else
    echo "$body" | jq -r '.choices[0].message.content'
  fi
}

# ── Map a changed component-side path to the matching umbrella file ───────────
#
# For non-live components, umbrella filenames match the component-side basename
# 1:1 (e.g. templates/deployment.yaml ↔ umbrella/deployment.yaml). Chart.yaml
# has no umbrella counterpart and is reported on its own.
#
# For castai-live the umbrella collapses each subdir / dependency into a single
# file:
#   helm/templates/<subdir>/foo.yaml       → <subdir>.yaml
#   helm/templates/<name>.yaml             → <name>.yaml
#   helm/dependencies/<dep>/templates/*    → <dep>.yaml (or fuzzy variants)

umbrella_file_for_component_path() {
  local comp_rel="$1"   # relative to COMPONENT_PATH, e.g. "templates/deployment.yaml"
  local base
  base=$(basename "$comp_rel")

  if [ "$CHART_NAME" = "castai-live" ]; then
    # helm/templates/<subdir>/foo.yaml → <subdir>.yaml
    if [[ "$comp_rel" == templates/*/* ]]; then
      local subdir
      subdir=$(echo "$comp_rel" | awk -F/ '{print $2}')
      echo "${UMB_TEMPLATES}/${subdir}.yaml"
      return 0
    fi
    # helm/templates/<file>.yaml → <file>.yaml
    if [[ "$comp_rel" == templates/* ]]; then
      echo "${UMB_TEMPLATES}/${base}"
      return 0
    fi
    # helm/dependencies/<dep>/templates/*.yaml → <dep>.yaml (or crds → crd.yaml)
    if [[ "$comp_rel" == dependencies/*/templates/* ]]; then
      local dep
      dep=$(echo "$comp_rel" | awk -F/ '{print $2}')
      # crds → crd.yaml special-case (matches existing matcher)
      [ "$dep" = "crds" ] && dep="crd"
      echo "${UMB_TEMPLATES}/${dep}.yaml"
      return 0
    fi
    # Anything else has no umbrella counterpart
    echo ""
    return 0
  fi

  # Non-live: 1:1 by basename, but only for files under templates/.
  if [[ "$comp_rel" == templates/* ]]; then
    echo "${UMB_TEMPLATES}/${base}"
    return 0
  fi

  # Chart.yaml or other component-root file: no umbrella counterpart.
  echo ""
  return 0
}

# ── Per-file AI calls ─────────────────────────────────────────────────────────

CASTAI_LIVE_NOTE=""
if [ "$CHART_NAME" = "castai-live" ]; then
  CASTAI_LIVE_NOTE="NOTE: castai-live's component templates live in subdirectories (controller/, daemon/, tc/) and dependency charts (aws-vpc-cni/, crds/, …) which are all flattened into single files in the umbrella (controller.yaml, daemon.yaml, tc.yaml, aws-vpc-cni.yaml, crd.yaml, …). Match resources by kind and name pattern, not by file path."
fi

AI_REPORT=""

for comp_path in "${TEMPLATE_FILES[@]}"; do
  rel="${comp_path#${COMPONENT_PATH}/}"
  echo "DEBUG: processing changed component file ${rel}" >&2

  # Compute the unified diff between the two tags for this file.
  file_diff=$(git -C "$REPO_CLONE_DIR" diff --no-color "${PREV_TAG}..${CURRENT_TAG}" -- "${comp_path}")
  if [ -z "$file_diff" ]; then
    # Shouldn't happen — git already told us this file changed.
    echo "DEBUG: empty diff for ${rel} — skipping" >&2
    continue
  fi

  # Chart.yaml drift is reported standalone (no umbrella counterpart).
  if [ "$(basename "$rel")" = "Chart.yaml" ]; then
    AI_REPORT+="### ${rel}

> ℹ️ Chart.yaml changed between \`${PREV_TAG}\` and \`${CURRENT_TAG}\` beyond the version/appVersion bump. Review manually — no umbrella counterpart exists for this file.

\`\`\`diff
${file_diff}
\`\`\`

"
    continue
  fi

  # Find the matching umbrella file.
  umb_path=$(umbrella_file_for_component_path "$rel")
  umb_fname=""
  umb_content=""
  if [ -n "$umb_path" ] && [ -f "$umb_path" ]; then
    umb_fname=$(basename "$umb_path")
    umb_content=$(cat "$umb_path")
  fi

  if [ -z "$umb_content" ]; then
    AI_REPORT+="### ${rel}

> ⚠️ Component file changed but no matching umbrella file was found (expected at \`${umb_path:-unknown}\`). Manual review required.

\`\`\`diff
${file_diff}
\`\`\`

"
    continue
  fi

  per_file_prompt="You are a Helm chart reviewer detecting structural drift.

CONTEXT:
- The umbrella chart is a near-verbatim copy of component templates, adapted with different .Values paths (e.g. \$pp.image.tag), different helper names, and an outer {{- \$pp := index .Values... }} binding. These are EXPECTED and should NOT be reported.
- ${CASTAI_LIVE_NOTE}
- The component file \`${rel}\` changed between tags \`${PREV_TAG}\` and \`${CURRENT_TAG}\`. The unified diff is below. Your job is to determine whether the CURRENT umbrella file already reflects each component-side change. If it does, the umbrella is in sync for that change. If it does not, that is drift.

COMPONENT DIFF (${rel}, ${PREV_TAG} → ${CURRENT_TAG}):
\`\`\`diff
${file_diff}
\`\`\`

CURRENT UMBRELLA FILE (${umb_fname}):
\`\`\`yaml
${umb_content}
\`\`\`

YOUR TASK:
For every semantic change visible in the component diff (additions, deletions, modifications to env, volumes, probes, ports, securityContext, resources, tolerations, affinity, nodeSelector, RBAC rules, initContainers, args, command, imagePullPolicy, serviceAccountName, hostNetwork, dnsPolicy, or any other spec field), check whether the current umbrella file already contains the equivalent value. Ignore expected adaptations (helper names, .Values paths, \$pp variable). Use this format per finding:
---
**Change in component:** <one-line summary of what changed in the diff>
**Resource:** \`<kind>/<name-pattern>\`
**Field:** \`<field path>\`
**Component (new value):**
\`\`\`yaml
<value or \"(absent)\">
\`\`\`
**Umbrella:**
\`\`\`yaml
<value or \"(absent)\">
\`\`\`
**Status:** IN SYNC | DRIFT
**Reason:** <one sentence>

---

Rules:
- IN SYNC: the umbrella already reflects this component change (modulo expected adaptations).
- DRIFT: the umbrella is missing this change or has a different value.
- One finding block per distinct semantic change.
- If every component-side change is already reflected in the umbrella, output EXACTLY this single line and nothing else: ✅ Umbrella in sync with ${rel} between ${PREV_TAG} and ${CURRENT_TAG}.
- Do NOT output the word \"None\", \"N/A\", an empty string, or any other placeholder.
- Use real markdown formatting (newlines, headings, fenced code blocks). Do NOT emit literal backslash-n escape sequences."

  file_report=$(call_kimchi "$per_file_prompt") || {
    AI_REPORT+="### ${rel}

> ❌ API call failed — skipped. See workflow logs for the HTTP status and error body.

"
    continue
  }

  # Normalise model output:
  #  - strip surrounding whitespace
  #  - convert literal backslash-n sequences to real newlines
  #  - collapse degenerate "None" / "N/A" / empty replies to the no-drift line
  file_report=$(printf '%s' "$file_report" \
    | python3 -c "import sys; s=sys.stdin.read().strip(); s=s.replace('\\\\n','\n'); print(s)")

  normalised=$(printf '%s' "$file_report" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]./\\"'\''`')
  case "$normalised" in
    ''|none|na|nodrift|null|nil|empty|nochanges|nochange|nodifference|nodifferences|insync|umbrellainsync*)
      file_report="✅ Umbrella in sync with ${rel} between \`${PREV_TAG}\` and \`${CURRENT_TAG}\`."
      ;;
  esac

  AI_REPORT+="### ${rel}

${file_report}

"
done

# ── Build the ignored-files appendix ──────────────────────────────────────────

IGNORED_BLOCK=""
if [ ${#IGNORED_FILES[@]} -gt 0 ]; then
  IGNORED_BLOCK=$'\n<details><summary>Filtered out '"${#IGNORED_FILES[@]}"$' non-template change(s)</summary>\n\n'
  for f in "${IGNORED_FILES[@]}"; do
    IGNORED_BLOCK+="- \`${f}\`"$'\n'
  done
  IGNORED_BLOCK+=$'\n</details>\n'
fi

# ── Build final report ────────────────────────────────────────────────────────

CHANGED_LIST=""
for f in "${TEMPLATE_FILES[@]}"; do
  CHANGED_LIST+="- \`${f#${COMPONENT_PATH}/}\`"$'\n'
done

REPORT="## Template drift: \`${CHART_NAME}\`

_Compared component tags \`${PREV_TAG}\` → \`${CURRENT_TAG}\` against umbrella \`${UMB_TEMPLATES}\` using ${KIMCHI_MODEL}._

**Changed template files:**
${CHANGED_LIST}
${AI_REPORT}${IGNORED_BLOCK}"

echo "$REPORT"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  DELIMITER="DRIFT_EOF_$(date +%s%N)"
  {
    echo "drift_report<<${DELIMITER}"
    echo "$REPORT"
    echo "${DELIMITER}"
  } >> "$GITHUB_OUTPUT"
fi
