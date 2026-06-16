{{/*
Expand the name of the chart.
*/}}
{{- define "evictor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "evictor.fullname" -}}
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
{{- define "evictor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "evictor.labels" -}}
{{ if gt (len .Values.commonLabels) 0 -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
helm.sh/chart: {{ include "evictor.chart" . }}
{{ include "evictor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "evictor.annotations" -}}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "evictor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "evictor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "evictor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "evictor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve tolerations: merge .Values.global.tolerations with .Values.tolerations.
*/}}
{{- define "evictor.tolerations" -}}
{{- $global := .Values.global | default dict -}}
{{- with concat ($global.tolerations | default list) (.Values.tolerations | default list) -}}
{{ toYaml . }}
{{- end -}}
{{- end }}

{{/*
Resolve image repository: prepend global.registry if set.
*/}}
{{- define "evictor.imageRepository" -}}
{{- $registry := ((.Values.global | default dict).registry) | default "" -}}
{{- if $registry -}}
{{- printf "%s/%s" (trimSuffix "/" $registry) .Values.image.repository -}}
{{- else -}}
{{- .Values.image.repository -}}
{{- end -}}
{{- end }}

{{/*
Resolve imagePullSecrets: merge global.imagePullSecrets with local imagePullSecrets.
*/}}
{{- define "evictor.imagePullSecrets" -}}
{{- $global := .Values.global | default dict -}}
{{- $combined := concat ($global.imagePullSecrets | default list) (.Values.imagePullSecrets | default list) -}}
{{- if $combined -}}
{{ toYaml $combined }}
{{- end -}}
{{- end }}

{{/*
Pass the customConfig to the configMap.
Supports legacy string mode (passed through as-is) and structured mode
(renders as evictionConfig: for arrays or customConfig.evictionRules for maps).
*/}}
{{- define "evictor.configMap.customConfig" -}}
{{- if .Values.customConfig }}
  {{- if kindIs "string" .Values.customConfig }}
    {{- /* Legacy string mode — pass through directly */ -}}
{{ .Values.customConfig | nindent 4 }}
  {{- else if kindIs "slice" .Values.customConfig }}
    {{- /* Structured array mode — wrap in evictionConfig: */ -}}
{{ "evictionConfig:" | nindent 4 }}
{{- toYaml .Values.customConfig | nindent 6 }}
  {{- else if .Values.customConfig.evictionRules }}
    {{- /* Map mode with nested evictionRules */ -}}
{{ "evictionConfig:" | nindent 4 }}
{{- toYaml .Values.customConfig.evictionRules | nindent 6 }}
  {{- end }}
{{- end }}
{{- end }}
