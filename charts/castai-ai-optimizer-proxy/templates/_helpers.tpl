{{/*
Expand the name of the chart.
*/}}
{{- define "ai-optimizer-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ai-optimizer-proxy.fullname" -}}
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
{{- define "ai-optimizer-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ai-optimizer-proxy.labels" -}}
helm.sh/chart: {{ include "ai-optimizer-proxy.chart" . }}
{{ include "ai-optimizer-proxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ai-optimizer-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-optimizer-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "ai-optimizer-proxy.annotations" -}}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ai-optimizer-proxy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ai-optimizer-proxy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "ai-optimizer-proxy.webhookName" -}}
{{ include "ai-optimizer-proxy.fullname" . }}
{{- end }}

{{- define "ai-optimizer-proxy.exludeSelfLabelSelectors" -}}
{{- range splitList "\n" (include "ai-optimizer-proxy.selectorLabels" .)  }}
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

{{- define "ai-optimizer-proxy.certsSecretName" -}}
{{ include "ai-optimizer-proxy.fullname" . }}-certs
{{- end }}
