{{/*
Expand the name of the chart.
*/}}
{{- define "chart-upgrader.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "chart-upgrader.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "chart-upgrader.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chart-upgrader.labels" -}}
helm.sh/chart: {{ include "chart-upgrader.chart" . }}
{{ include "chart-upgrader.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart-upgrader.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart-upgrader.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "chart-upgrader.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- .Values.serviceAccount.name | default (include "chart-upgrader.fullname" .) }}
{{- else }}
{{- .Values.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
Name of the Helm release to upgrade. Required.
*/}}
{{- define "chart-upgrader.targetRelease" -}}
{{- required ".Values.targetRelease is required" .Values.targetRelease -}}
{{- end }}

{{/*
Namespace where the target release lives. Required.
*/}}
{{- define "chart-upgrader.targetNamespace" -}}
{{- required ".Values.targetNamespace is required" .Values.targetNamespace -}}
{{- end }}
