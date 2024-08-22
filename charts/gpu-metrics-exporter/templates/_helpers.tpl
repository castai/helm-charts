{{/*
Expand the name of the chart.
*/}}
{{- define "gpu-metrics-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gpu-metrics-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gpu-metrics-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gpu-metrics-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gpu-metrics-exporter.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gpu-metrics-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gpu-metrics-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
GPU metrics exporter labels
*/}}
{{- define "gpu-metrics-exporter.labels" -}}
helm.sh/chart: {{ include "gpu-metrics-exporter.chart" . }}
{{ include "gpu-metrics-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create the name of the dcgm-exporter config map
*/}}
{{- define "dcgm-exporter.config-map" -}}
{{- printf "%s-%s" .Release.Name "dcgm-metrics" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the gpu-metrics-exporter config map
*/}}
{{- define "gpu-metrics-exporter.config-map" -}}
{{- printf "%s-%s" .Release.Name "gpu-metrics-exporter" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}