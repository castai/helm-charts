#!/usr/bin/env bash
# Detects structural drift between a component's Helm templates and the
# corresponding copied templates in the kubecast umbrella chart.
#
# Uses Kimchi Inference (minimax-m3) to semantically compare templates,
# handling the fact that umbrella templates have different Go template syntax
# (.Values paths, helper names, $pp variables) but should represent the same
# Kubernetes resource structure.
#
# Required env vars:
#   CHART_NAME        — e.g. castai-agent, castai-pod-pinner, castai-live
#   KIMCHI_API_KEY    — Kimchi Inference API key
#   CHART_VERSION     — required only for castai-live (cloned from GitLab at tag v<version>)
#   GITLAB_TOKEN      — required only for castai-live (to clone gitlab.com/castai/live/clm)
#
# Paths expected to exist at call time:
#   kubecast/         — clone of the kubecast repo
#   helm-charts/      — optional, for evictor / chart-upgrader
#
# Writes markdown to stdout and, when GITHUB_OUTPUT is set, appends:
#   drift_report<<DELIMITER / ... / DELIMITER

set -euo pipefail

CHART_NAME="${CHART_NAME:?CHART_NAME env var required}"
CHART_VERSION="${CHART_VERSION:-}"
KIMCHI_API_KEY="${KIMCHI_API_KEY:?KIMCHI_API_KEY env var required}"

KIMCHI_API_URL="https://llm.kimchi.dev/openai/v1/chat/completions"
KIMCHI_MODEL="minimax-m3"

# ── Locate component templates ────────────────────────────────────────────────

COMP_TEMPLATES=""
COMP_DEPS_DIR=""

if [ "$CHART_NAME" = "castai-live" ]; then
  if [ -z "$CHART_VERSION" ]; then
    echo "CHART_VERSION is required for castai-live" >&2
    exit 1
  fi
  GITLAB_TOKEN="${GITLAB_TOKEN:?GITLAB_TOKEN env var required for castai-live}"

  LIVE_CLONE_DIR="/tmp/castai-live-source"
  rm -rf "$LIVE_CLONE_DIR"

  git clone \
    --depth 1 \
    --branch "v${CHART_VERSION}" \
    "https://oauth2:${GITLAB_TOKEN}@gitlab.com/castai/live/clm.git" \
    "$LIVE_CLONE_DIR"

  COMP_TEMPLATES="${LIVE_CLONE_DIR}/helm/templates"
  COMP_DEPS_DIR="${LIVE_CLONE_DIR}/helm/dependencies"
else
  CHART_YAML_PATH=$(find kubecast/services -name "Chart.yaml" \
    -exec grep -l "^name: ${CHART_NAME}$" {} \; 2>/dev/null | head -1 || true)

  if [ -z "$CHART_YAML_PATH" ] && [ -d "helm-charts/charts/${CHART_NAME}" ]; then
    CHART_YAML_PATH="helm-charts/charts/${CHART_NAME}/Chart.yaml"
  fi

  if [ -z "$CHART_YAML_PATH" ]; then
    cat <<MD
## Template drift: \`${CHART_NAME}\`

> Chart not found in \`kubecast/services/\` or \`helm-charts/charts/\` — skipping drift check.
MD
    exit 0
  fi
  COMP_TEMPLATES="$(dirname "$CHART_YAML_PATH")/templates"
fi

UMB_TEMPLATES="kubecast/castai-umbrella/chart/templates/${CHART_NAME}"

if [ ! -d "$COMP_TEMPLATES" ]; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> Component templates not found at \`${COMP_TEMPLATES}\` — skipping drift check.
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

# ── Kimchi API call helper ────────────────────────────────────────────────────

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

# ── Find matching component files for an umbrella filename ───────────────────
# For castai-live, umbrella files are flattened from subdirs and deps:
#   controller.yaml  ← helm/templates/controller/*.yaml
#   daemon.yaml      ← helm/templates/daemon/*.yaml
#   tc.yaml          ← helm/templates/tc/*.yaml
#   aws-vpc-cni.yaml ← helm/dependencies/aws-vpc-cni/templates/*.yaml
#   crd.yaml         ← helm/dependencies/crds/templates/*.yaml
# For other charts, filenames match 1:1.

get_comp_content_for_umb() {
  local umb_fname="$1"
  local base="${umb_fname%.yaml}"
  local out=""

  if [ "$CHART_NAME" = "castai-live" ]; then
    # Check for a matching subdir in helm/templates/<base>/
    local subdir="${COMP_TEMPLATES}/${base}"
    if [ -d "$subdir" ]; then
      while IFS= read -r -d '' f; do
        local fname
        fname=$(basename "$f")
        [[ "$fname" == _* ]] && continue
        out+="### File: ${base}/${fname}\n\`\`\`yaml\n$(cat "$f")\n\`\`\`\n\n"
      done < <(find "$subdir" -name '*.yaml' -o -name '*.tpl' | sort | tr '\n' '\0')
    fi

    # Check for a matching file directly in helm/templates/<base>.yaml
    local direct_file="${COMP_TEMPLATES}/${umb_fname}"
    if [ -f "$direct_file" ]; then
      out+="### File: ${umb_fname}\n\`\`\`yaml\n$(cat "$direct_file")\n\`\`\`\n\n"
    fi

    # Check for a matching dependency in helm/dependencies/
    if [ -d "$COMP_DEPS_DIR" ]; then
      # Try exact dep name match (e.g. aws-vpc-cni.yaml -> aws-vpc-cni/)
      local dep_dir="${COMP_DEPS_DIR}/${base}"
      if [ -d "${dep_dir}/templates" ]; then
        while IFS= read -r -d '' f; do
          local fname
          fname=$(basename "$f")
          [[ "$fname" == _* ]] && continue
          out+="### File: ${base}/${fname}\n\`\`\`yaml\n$(cat "$f")\n\`\`\`\n\n"
        done < <(find "${dep_dir}/templates" -name '*.yaml' -o -name '*.tpl' | sort | tr '\n' '\0')
      fi

      # Also try fuzzy match: dep dir name contains base or base contains dep name
      # e.g. crd.yaml -> crds/, aws-vpc-cni-extra.yaml -> aws-vpc-cni-extra/
      for dep in "$COMP_DEPS_DIR"/*/; do
        [ -d "$dep" ] || continue
        local dep_name
        dep_name=$(basename "$dep")
        [ "$dep_name" = "$base" ] && continue  # already handled above
        if [[ "$dep_name" == "$base"* ]] || [[ "$base" == "$dep_name"* ]] || [[ "$dep_name" == "crds" && "$base" == "crd" ]]; then
          if [ -d "${dep}/templates" ]; then
            while IFS= read -r -d '' f; do
              local fname
              fname=$(basename "$f")
              [[ "$fname" == _* ]] && continue
              out+="### File: ${dep_name}/${fname}\n\`\`\`yaml\n$(cat "$f")\n\`\`\`\n\n"
            done < <(find "${dep}/templates" -name '*.yaml' -o -name '*.tpl' | sort | tr '\n' '\0')
          fi
        fi
      done
    fi
  else
    # Non-live: match by filename directly
    local match
    match=$(find "$COMP_TEMPLATES" -name "${umb_fname}" | head -1 || true)
    if [ -n "$match" ]; then
      out+="### File: ${umb_fname}\n\`\`\`yaml\n$(cat "$match")\n\`\`\`\n\n"
    fi
  fi

  echo -e "$out"
}

# ── Build context note ────────────────────────────────────────────────────────

CASTAI_LIVE_NOTE=""
if [ "$CHART_NAME" = "castai-live" ]; then
  CASTAI_LIVE_NOTE="NOTE: castai-live's component templates are split across subdirectories (controller/, daemon/, tc/) and dependency charts (aws-vpc-cni, crds, etc.) which are all flattened into single files in the umbrella (controller.yaml, daemon.yaml, tc.yaml, aws-vpc-cni.yaml, crd.yaml, etc.). Match resources by kind and name pattern — do not report drift just because a resource appears in a different file. Report ALL structural differences; the reviewer will decide what is intentional."
fi

# ── Call Kimchi per umbrella file ─────────────────────────────────────────────

AI_REPORT=""

while IFS= read -r -d '' umb_file; do
  umb_fname=$(basename "$umb_file")
  umb_content=$(cat "$umb_file")

  echo "DEBUG: processing umbrella file ${umb_fname}" >&2

  matched_comp=$(get_comp_content_for_umb "$umb_fname")

  if [ -z "$matched_comp" ]; then
    echo "DEBUG: no matching component files found for ${umb_fname}" >&2
    AI_REPORT+="### ${umb_fname}\n> ⚠️ No matching component file found — may be an umbrella-only addition.\n\n"
    continue
  fi

  per_file_prompt="You are a Helm chart reviewer detecting structural drift.

CONTEXT:
- The umbrella chart is a near-verbatim copy of component templates, adapted with different .Values paths (e.g. \$pp.image.tag), different helper names, and an outer {{- \$pp := index .Values... }} binding. These are EXPECTED and should NOT be reported.
- ${CASTAI_LIVE_NOTE}

UMBRELLA FILE: ${umb_fname}
\`\`\`yaml
${umb_content}
\`\`\`

COMPONENT FILES (matched to this umbrella file):
${matched_comp}

YOUR TASK:
Compare every Kubernetes resource in the umbrella file against the component files. For each difference found in any of these fields:
- env / envFrom entries (name, value, valueFrom)
- volumes and volumeMounts (name, mountPath, type)
- livenessProbe / readinessProbe / startupProbe
- ports (name, containerPort, protocol)
- securityContext (pod-level and container-level)
- resources (requests and limits)
- tolerations, affinity, nodeSelector, topologySpreadConstraints
- RBAC rules (apiGroups, resources, verbs)
- initContainers and sidecars
- args and command
- imagePullPolicy, serviceAccountName, hostNetwork, dnsPolicy
- Any other spec fields present in either side

Output exactly this format per difference:
---
**Resource:** \`<kind>/<name-pattern>\`
**Field:** \`<field path>\`
**Component:**
\`\`\`yaml
<value or \"(absent)\">
\`\`\`
**Umbrella:**
\`\`\`yaml
<value or \"(absent)\">
\`\`\`
**Classification:** ACTION REQUIRED | INFORMATIONAL
**Reason:** <one sentence>

---

Rules:
- ACTION REQUIRED: component has something the umbrella is missing or has differently.
- INFORMATIONAL: umbrella has something the component doesn't.
- One finding block per differing field. Do NOT group or summarize.
- If no drift, output only: \"✅ No drift in ${umb_fname}.\""

  file_report=$(call_kimchi "$per_file_prompt") || {
    AI_REPORT+="### ${umb_fname}\n> ❌ API call failed — skipped.\n\n"
    continue
  }
  AI_REPORT+="### ${umb_fname}\n${file_report}\n\n"

done < <(find "$UMB_TEMPLATES" -name '*.yaml' | sort | tr '\n' '\0')

# ── Build final report ────────────────────────────────────────────────────────

REPORT="## Template drift: \`${CHART_NAME}\`

_Compared \`${COMP_TEMPLATES}\` (component) vs \`${UMB_TEMPLATES}\` (umbrella) using ${KIMCHI_MODEL}._

${AI_REPORT}"

echo "$REPORT"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  DELIMITER="DRIFT_EOF_$(date +%s%N)"
  {
    echo "drift_report<<${DELIMITER}"
    echo "$REPORT"
    echo "${DELIMITER}"
  } >> "$GITHUB_OUTPUT"
fi
