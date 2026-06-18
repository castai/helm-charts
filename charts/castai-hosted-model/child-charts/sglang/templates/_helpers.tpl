{{/*
Expand the name of the chart.
*/}}
{{- define "sglang.fullname" -}}
{{ .Values.service.name }}
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
