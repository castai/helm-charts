{{/*
Expand the name of the chart.
service.name is normally provided by the parent chart's per-model values. Fall
back to a Release-derived name so resources never render with an empty name.
*/}}
{{- define "sglang.fullname" -}}
{{ .Values.service.name | default (printf "%s-sglang" .Release.Name) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sglang.chart" -}}
{{- printf "%s-%s" "sglang" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sglang.labels" -}}
helm.sh/chart: {{ include "sglang.chart" . }}
model.aibrix.ai/name: {{ include "sglang.fullname" . }}
{{ include "sglang.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sglang.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sglang.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the HuggingFace token secret.
*/}}
{{- define "sglang.hfSecretName" -}}
{{- printf "%s-model-registry" (include "sglang.fullname" .) -}}
{{- end }}
