{{/*
Expand the name of the chart.
*/}}
{{- define "pod-mutator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pod-mutator.fullname" -}}
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
{{- define "pod-mutator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pod-mutator.labels" -}}
{{- if gt (len .Values.global.commonLabels) 0 }}
{{- with .Values.global.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
helm.sh/chart: {{ include "pod-mutator.chart" . }}
{{ include "pod-mutator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pod-mutator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pod-mutator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "pod-mutator.webhookName" -}}
{{ include "pod-mutator.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pod-mutator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pod-mutator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "pod-mutator.exludeSelfLabelSelectors" -}}
{{- range splitList "\n" (include "pod-mutator.selectorLabels" .)  }}
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

{{- define "pod-mutator.certsSecretName" -}}
{{ include "pod-mutator.fullname" . }}-certs
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "pod-mutator.annotations" -}}
{{- if gt (len .Values.global.commonAnnotations) 0 }}
{{- with .Values.global.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}