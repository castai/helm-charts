{{/*
Expand the name of the chart.
*/}}
{{- define "vllm.fullname" -}}
{{ .Values.service.name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vllm.chart" -}}
{{- printf "%s-%s" "vllm" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vllm.labels" -}}
helm.sh/chart: {{ include "vllm.chart" . }}
model.aibrix.ai/name: {{ include "vllm.fullname" . }}
{{ include "vllm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vllm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vllm.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Check if model.sourceRegistry or loraAdapter.sourceRegistry requires a specific registry
Usage: {{ if include "requiresRegistry" (list "gcs" .) }}
*/}}
{{- define "requiresRegistry" -}}
{{- $registry := index . 0 -}}
{{- $ctx := index . 1 -}}
{{- if or (eq $ctx.Values.model.sourceRegistry $registry) (eq $ctx.Values.loraAdapter.sourceRegistry $registry) -}}
{{- $registry -}}
{{- end -}}
{{- end }}


{{/*
Get the registry secret name, defaulting to the chart's fullname
Usage: {{ include "registrySecretName" . }}
*/}}
{{- define "registrySecretName" -}}
{{- .Values.registries.secretName | default (include "vllm.fullname" .) -}}
{{- end }}

{{/*
Create model reference based on source registry
Usage {{ include "modelReference" . }}
*/}}
{{- define "modelReference" -}}
{{- if eq .Values.model.sourceRegistry "hf" -}}
{{ .Values.model.name }}
{{- else -}}
s3://{{ .Values.model.name }}
{{- end -}}
{{- end }}
