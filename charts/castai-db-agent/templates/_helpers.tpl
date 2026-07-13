{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "castai-db-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "castai-db-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define common labels.
*/}}
{{- define "castai-db-agent.labels" -}}
app.kubernetes.io/managed-by: Helm
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/name: {{ include "castai-db-agent.name" . }}
helm.sh/chart: {{ include "castai-db-agent.chart" . }}
{{- end }}

{{- define "castai-db-agent.dbAgentImage" -}}
{{-  default (include "castai-db-agent.defaultDbAgentVersion" .) .Values.image.tag }}
{{- end }}

{{- define "castai-db-agent.cloudSqlProxyImage" -}}
{{-  default (include "castai-db-agent.defaultCloudSqlProxyVersion" .) .Values.cloudSqlProxyImage.tag }}
{{- end }}

{{- define "castai-db-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "castai-db-agent.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
