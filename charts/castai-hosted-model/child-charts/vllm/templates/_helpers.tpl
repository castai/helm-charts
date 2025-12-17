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
Get the registry secret names, defaulting to the chart's fullname with a proper suffix
Usage: {{ include "modelRegistrySecretName" . }}
*/}}
{{- define "modelRegistrySecretName" -}}
{{- .Values.model.registry.secretName | default (printf "%s-model-registry" (include "vllm.fullname" .)) -}}
{{- end }}

{{- define "loraRegistrySecretName" -}}
{{- .Values.loraAdapter.registry.secretName | default (printf "%s-lora-registry" (include "vllm.fullname" .)) -}}
{{- end }}

{{/*
Create model reference based on source registry
Usage {{ include "modelReference" . }}
*/}}
{{- define "modelReference" -}}
{{- if eq .Values.model.sourceRegistry "hf" -}}
{{ .Values.model.name }}
{{- else if and .Values.useRunAiStreamer (eq .Values.model.sourceRegistry "gcs") -}}
gs://{{ .Values.model.name }}
{{- else if and .Values.useRunAiStreamer (eq .Values.model.sourceRegistry "s3") -}}
s3://{{ .Values.model.name }}
{{- else -}}
/models/{{ .Values.model.name }}
{{- end -}}
{{- end }}

{{/*
Generate comma-separated list of model directories
Usage: {{ include "modelDownloader.remoteSourceDirs" . }}
*/}}
{{- define "modelDownloader.remoteSourceDirs" -}}
{{- $dirs := list -}}
{{- if .Values.loraAdapter.name -}}
  {{- $dirs = append $dirs .Values.loraAdapter.name -}}
{{- end -}}
{{- if and (ne .Values.model.sourceRegistry "hf") (not .Values.useRunAiStreamer) -}}
  {{- $dirs = append $dirs .Values.model.name -}}
{{- end -}}
{{- join "," $dirs -}}
{{- end }}
