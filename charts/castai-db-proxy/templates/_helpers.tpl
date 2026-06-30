{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "castai-db-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "castai-db-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define common labels.
*/}}
{{- define "castai-db-proxy.labels" -}}
{{- if .Values.commonLabels }}
{{ if gt (len .Values.commonLabels) 0 -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
app.kubernetes.io/managed-by: Helm
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
helm.sh/chart: {{ include "castai-db-proxy.chart" . }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "castai-db-proxy.annotations" -}}
{{- if .Values.commonAnnotations }}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "castai-db-proxy.proxyImage" -}}
{{- default (include "castai-db-proxy.defaultProxyVersion" .) .Values.image.tag }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "castai-db-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
{{- end }}
