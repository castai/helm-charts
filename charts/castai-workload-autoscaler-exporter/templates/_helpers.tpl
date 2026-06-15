{{/*
Resolve image repository: prepend global.registry if set.
*/}}
{{- define "exporter.imageRepository" -}}
{{- $repository := required "image.repository must be provided" (index . 0) -}}
{{- $registry := ((index . 1).Values.global | default dict).registry | default "" -}}
{{- if $registry -}}
{{- printf "%s/%s" (trimSuffix "/" $registry) $repository -}}
{{- else -}}
{{- $repository -}}
{{- end -}}
{{- end }}

{{- define "exporter.exporter.imageRepository" -}}
{{- include "exporter.imageRepository" (list .Values.exporter.image.repository .) -}}
{{- end }}

{{- define "exporter.prometheus.imageRepository" -}}
{{- include "exporter.imageRepository" (list .Values.prometheus.image.repository .) -}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "exporter.fullname" -}}
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
{{- define "exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "exporter.labels" -}}
helm.sh/chart: {{ include "exporter.chart" . }}
{{ include "exporter.selectorLabels" . }}
{{- $appVersion := .Values.appVersion | default .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Resolve imagePullSecrets: merge global.imagePullSecrets with local imagePullSecrets.
*/}}
{{- define "exporter.imagePullSecrets" -}}
{{- $global := .Values.global | default dict -}}
{{- $combined := concat ($global.imagePullSecrets | default list) (.Values.imagePullSecrets | default list) -}}
{{- if $combined -}}
{{ toYaml $combined }}
{{- end -}}
{{- end }}

{{/*
Merge global and chart-level tolerations.
*/}}
{{- define "exporter.tolerations" -}}
{{- $global := .Values.global | default dict -}}
{{- with concat ($global.tolerations | default list) (.Values.tolerations | default list) -}}
{{ toYaml . }}
{{- end -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "exporter.serviceAccountName" -}}
{{- if .Values.exporter.serviceAccount.create }}
{{- default (include "exporter.fullname" .) .Values.exporter.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.exporter.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve the node metrics mode, handling both defined and undefined cases.
Returns: "api-server" (default) or "kubelet"
*/}}
{{- define "exporter.nodeMetricsMode" -}}
{{- $validModes := list "api-server" "kubelet" -}}
{{- $mode := .Values.exporter.config.nodeMetrics.mode | default "api-server" -}}
{{- if has $mode $validModes -}}
{{- $mode -}}
{{- else -}}
api-server
{{- end -}}
{{- end -}}
