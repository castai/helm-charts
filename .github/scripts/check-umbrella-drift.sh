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
#   CHART_VERSION     — required only for castai-live (pulled from registry)
#
# Paths expected to exist at call time:
#   kubecast/         — clone of the kubecast repo
#   helm-charts/      — optional, for evictor / chart-upgrader
#
# For castai-live, the chart is pulled from the public Helm registry.
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

  COMP_TEMPLATES="${LIVE_CLONE_DIR}/helm"
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

# ── Collect template file contents ────────────────────────────────────────────

collect_templates() {
  local dir="$1"
  local label="$2"
  local out=""
  while IFS= read -r -d '' f; do
    local fname
    fname=$(basename "$f")
    # Skip helpers/_helpers.tpl — pure Go template definitions, no K8s resources
    [[ "$fname" == _* ]] && continue
    out+="### File: ${fname}\n\`\`\`yaml\n$(cat "$f")\n\`\`\`\n\n"
  done < <(find "$dir" -name '*.yaml' -o -name '*.tpl' | sort | tr '\n' '\0')
  echo -e "$out"
}

COMP_CONTENT=$(collect_templates "$COMP_TEMPLATES" "component")
UMB_CONTENT=$(collect_templates "$UMB_TEMPLATES" "umbrella")

if [ -z "$COMP_CONTENT" ]; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> No template files found in component at \`${COMP_TEMPLATES}\`.
MD
  exit 0
fi

if [ -z "$UMB_CONTENT" ]; then
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> No template files found in umbrella at \`${UMB_TEMPLATES}\`.
MD
  exit 0
fi

# ── Build prompt ──────────────────────────────────────────────────────────────

# castai-live note: its templates dir may contain flattened dependency templates
CASTAI_LIVE_NOTE=""
if [ "$CHART_NAME" = "castai-live" ]; then
  CASTAI_LIVE_NOTE="NOTE: castai-live's component templates directory may contain flattened templates \
from chart dependencies. However, you must still report ALL differences you find — do not skip or \
excuse any diff on the grounds that it might belong to a dependency. Flag everything; the reviewer \
will decide what is intentional."
fi

PROMPT="You are a Helm chart reviewer. Your job is to detect **structural drift** between a component's original Helm templates and a copied version of those templates inside an umbrella chart.

CONTEXT:
- The umbrella chart is a near-verbatim copy of the component chart's templates, adapted to fit inside a larger umbrella Helm chart.
- Adaptations include: different .Values paths (e.g. \$pp.image.tag instead of .Values.image.tag), different helper function names (e.g. umbrella.castai-pod-pinner.fullname instead of pod-pinner.fullname), and an outer {{- \$pp := index .Values... }} variable binding.
- These syntactic differences are EXPECTED and should NOT be reported as drift.
- What matters is the Kubernetes resource structure: which resource kinds exist, what fields they contain, what RBAC rules are defined, what env vars, volumes, volumeMounts, probes, ports, affinity rules, tolerations, sidecars, etc.

${CASTAI_LIVE_NOTE}

YOUR TASK:
Go through every Kubernetes resource in both template sets. For each resource (matched by kind and name pattern):

1. Extract and compare these fields exhaustively between component and umbrella:
   - env / envFrom entries (name, value, valueFrom)
   - volumes and volumeMounts (name, mountPath, type)
   - livenessProbe / readinessProbe / startupProbe (path, port, scheme, thresholds)
   - ports (name, containerPort, protocol)
   - securityContext (pod-level and container-level)
   - resources (requests and limits)
   - tolerations, affinity, nodeSelector, topologySpreadConstraints
   - RBAC rules (apiGroups, resources, verbs)
   - initContainers and sidecars
   - args and command
   - imagePullPolicy, serviceAccountName, hostNetwork, dnsPolicy
   - Any other spec fields present in either side

2. For each field that differs or is absent on one side, output a finding block in exactly this format:

---
**Resource:** \`<kind>/<name-pattern>\`
**Field:** \`<exact field path, e.g. spec.template.spec.containers[0].env[KARPENTER_MODE_ENABLED]>\`
**Component:**
\`\`\`yaml
<exact lines from the component template, or \"(absent)\" if missing>
\`\`\`
**Umbrella:**
\`\`\`yaml
<exact lines from the umbrella template, or \"(absent)\" if missing>
\`\`\`
**Classification:** ACTION REQUIRED | INFORMATIONAL
**Reason:** <one sentence: what this means and why it matters>

---

3. Rules for classification:
   - ACTION REQUIRED: component has something the umbrella is missing or has differently — umbrella needs updating.
   - INFORMATIONAL: umbrella has something the component doesn't — may be intentional addition or stale; reviewer must verify.

4. For entire resources missing from one side, output one finding block for the whole resource with the full resource yaml in the relevant side's field.

5. If there is zero drift after checking all fields, output only: \"✅ No structural drift detected.\"

6. Do NOT group findings. One finding block per differing field. Do NOT summarize or omit fields — exhaustive coverage is required.

---

## COMPONENT TEMPLATES (\`${COMP_TEMPLATES}\`)

${COMP_CONTENT}

---

## UMBRELLA TEMPLATES (\`${UMB_TEMPLATES}\`)

${UMB_CONTENT}

---

Now produce the drift report. Be exhaustive. Show exact lines."

# ── Call Kimchi Inference API ─────────────────────────────────────────────────

# Escape prompt for JSON — use python if available, else fall back to sed
if command -v python3 &>/dev/null; then
  PROMPT_JSON=$(python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))" <<< "$PROMPT")
else
  # Minimal escaping: backslash, double-quote, newline, tab
  PROMPT_JSON=$(printf '%s' "$PROMPT" \
    | sed 's/\\/\\\\/g; s/"/\\"/g' \
    | awk '{printf "%s\\n", $0}' \
    | sed 's/\\n$//' \
    | sed 's/\t/\\t/g')
  PROMPT_JSON="\"${PROMPT_JSON}\""
fi

REQUEST_BODY=$(cat <<EOF
{
  "model": "${KIMCHI_MODEL}",
  "max_tokens": 4096,
  "messages": [
    {
      "role": "user",
      "content": ${PROMPT_JSON}
    }
  ]
}
EOF
)

HTTP_RESPONSE=$(curl -sf \
  -X POST "$KIMCHI_API_URL" \
  -H "Authorization: Bearer ${KIMCHI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY" 2>&1) || {
  cat <<MD
## Template drift: \`${CHART_NAME}\`

> ❌ Kimchi API call failed. Check that KIMCHI_API_KEY is set correctly and the API is reachable.
> Error: ${HTTP_RESPONSE}
MD
  exit 1
}

# Extract the model's reply from the OpenAI-format response
if command -v python3 &>/dev/null; then
  AI_REPORT=$(python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
print(data['choices'][0]['message']['content'])
" <<< "$HTTP_RESPONSE")
elif command -v jq &>/dev/null; then
  AI_REPORT=$(echo "$HTTP_RESPONSE" | jq -r '.choices[0].message.content')
else
  echo "Error: neither python3 nor jq available to parse API response" >&2
  exit 1
fi

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
