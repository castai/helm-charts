{{/*
Expand the name of the chart.
*/}}
{{- define "omni-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "omni-agent.fullname" -}}
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
{{- define "omni-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "omni-agent.labels" -}}
{{ if gt (len .Values.commonLabels) 0 -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
helm.sh/chart: {{ include "omni-agent.chart" . }}
{{ include "omni-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: omni-agent
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "omni-agent.annotations" -}}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "omni-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "omni-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "omni-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "omni-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate a map of resource quantities (e.g. requests or limits).
Usage: {{ include "omni-agent.validateResources" (dict "quantities" .Values.edgeCluster.resources.requests "path" "edgeCluster.resources.requests") }}
*/}}
{{- define "omni-agent.validateResources" -}}
{{- $re := `^([+-]?[0-9.]+)(([eE][-+]?[0-9]+)|([EPTGMK]i?)|[mknuμ])?$` -}}
{{- range $field, $value := .quantities }}
{{- if $value }}
{{- if not (regexMatch $re ($value | toString)) }}
{{- fail (printf "invalid resource quantity %q for %s.%s: must be a valid Kubernetes resource quantity (e.g. 100m, 128Mi, 1Gi)" $value $.path $field) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Pass the customConfig to the configMap
*/}}
{{- define "omni-agent.configMap.customConfig" -}}
{{- if .Values.customConfig }}
{{ .Values.customConfig | nindent 4 }}
{{- end }}
{{- end }}
