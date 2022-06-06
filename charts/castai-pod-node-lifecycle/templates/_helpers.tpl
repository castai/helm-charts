{{/*
Expand the name of the chart.
*/}}
{{- define "pod-node-lifecycle.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pod-node-lifecycle.fullname" -}}
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
{{- define "pod-node-lifecycle.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pod-node-lifecycle.labels" -}}
helm.sh/chart: {{ include "pod-node-lifecycle.chart" . }}
{{ include "pod-node-lifecycle.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pod-node-lifecycle.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pod-node-lifecycle.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pod-node-lifecycle.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pod-node-lifecycle.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "pod-node-lifecycle.certsSecretName" -}}
{{ include "pod-node-lifecycle.fullname" . }}-certs
{{- end }}

{{- define "pod-node-lifecycle.configMapName" -}}
{{- if .Values.syncer.enabled }}
{{- .Values.syncer.targetConfigmap }}
{{- else }}
{{- include "pod-node-lifecycle.fullname" . }}-rtconfig
{{- end }}
{{- end }}

{{- define "pod-node-lifecycle.staticConfig" -}}
{{ $content := "" }}
{{- if .Values.staticConfig.preset }}
{{ $content = required (printf "unknown preset set in .Values.staticConfig.preset: %s" .Values.staticConfig.preset) (get .Values.staticConfig.presets .Values.staticConfig.preset) }}
{{- else }}
{{- $content = required "missing '.Values.staticConfig.stringValue' either .Values.staticConfig.stringTemplate or .Values.staticConfig.preset' must be provided" .Values.staticConfig.stringTemplate }}
{{- end }}
{{- tpl $content . }}
{{- end }}

{{- define "pod-node-lifecycle.webhookName" -}}
{{ include "pod-node-lifecycle.fullname" . }}
{{- end }}

{{- define "pod-node-lifecycle.exludeSelfLabelSelectors" -}}
{{- range splitList "\n" (include "pod-node-lifecycle.selectorLabels" .)  }}
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
