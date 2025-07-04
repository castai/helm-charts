{{/*
Expand the name of the chart.
*/}}
{{- define "watchdog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "watchdog.fullname" -}}
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
{{- define "watchdog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "watchdog.labels" -}}
{{- if gt (len .Values.global.commonLabels) 0 }}
{{- with .Values.global.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
helm.sh/chart: {{ include "watchdog.chart" . }}
{{ include "watchdog.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "watchdog.selectorLabels" -}}
app.kubernetes.io/name: {{ include "watchdog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "watchdog.webhookName" -}}
{{ include "watchdog.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "watchdog.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "watchdog.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "watchdog.exludeSelfLabelSelectors" -}}
{{- range splitList "\n" (include "watchdog.selectorLabels" .)  }}
  {{- /* we split label keypair by `:`. Let's hope there are no `:` in the key*/ -}}
  {{- $parts := splitn ":" 2 . -}}
  {{- $key := trim $parts._0 -}}
  {{- $value := trim $parts._1 }}
- key: {{ $key | quote }}
  operator: NotIn
  values:
    - {{ $value | quote }}
{{- end }}
{{- end }}

{{- define "watchdog.certsSecretName" -}}
{{ include "watchdog.fullname" . }}-certs
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "watchdog.annotations" -}}
{{- if gt (len .Values.global.commonAnnotations) 0 }}
{{- with .Values.global.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
