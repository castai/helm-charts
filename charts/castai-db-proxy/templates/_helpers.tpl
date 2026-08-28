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

{{- define "castai-db-proxy.proxySelectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
app.kubernetes.io/component: proxy
{{- end }}

{{- define "castai-db-proxy.poolingSelectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
app.kubernetes.io/component: pooling
{{- end }}

{{- define "castai-db-proxy.poolingConfigManagerImage" -}}
{{- default (include "castai-db-proxy.defaultPoolingConfigManagerVersion" .) .Values.pooling.configManager.image.tag }}
{{- end }}

{{- define "castai-db-proxy.pgdogImage" -}}
{{- default (include "castai-db-proxy.defaultPgdogVersion" .) .Values.pooling.pgdog.image.tag }}
{{- end }}

{{- define "castai-db-proxy.proxySqlImage" -}}
{{- default (include "castai-db-proxy.defaultProxySqlVersion" .) .Values.pooling.proxySql.image.tag }}
{{- end }}

{{/*
Worker threads for each proxy listener that serves traffic.

An explicit .Values.serverThreads wins; otherwise derive from the CPU request rounded
up, with a floor of 1. Accepts both core ("2") and millicore ("1500m") notation.
One worker per core matches the tokio runtime pingora builds on, which defaults to
one worker thread per available core.
*/}}
{{- define "castai-db-proxy.workerThreads" -}}
{{- if .Values.serverThreads -}}
{{- .Values.serverThreads | int -}}
{{- else -}}
{{- $cpu := .Values.resources.cpu | toString -}}
{{- $cores := 0.0 -}}
{{- if hasSuffix "m" $cpu -}}
{{- $cores = divf (float64 (trimSuffix "m" $cpu)) 1000.0 -}}
{{- else -}}
{{- $cores = float64 $cpu -}}
{{- end -}}
{{- max 1 (int (ceil $cores)) -}}
{{- end -}}
{{- end -}}
