{{/*
Expand the name of the chart.
*/}}
{{- define "cluster-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cluster-controller.fullname" -}}
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
{{- define "cluster-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cluster-controller.labels" -}}
{{- with .Values.global }}
{{- with .commonLabels }}
{{- toYaml . }}
{{ end }}
{{- end }}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{ end }}
helm.sh/chart: {{ include "cluster-controller.chart" . }}
{{ include "cluster-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "cluster-controller.annotations" -}}
{{- with .Values.global }}
{{- with .commonAnnotations }}
{{- toYaml . }}
{{ end }}
{{- end }}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{ end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cluster-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cluster-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cluster-controller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "cluster-controller.workloadAutoscalingEnabled" -}}
  {{- $workloadAutoscalingEnabled := true -}}
  {{- if .Values.workloadAutoscaling -}}
    {{- $workloadAutoscalingEnabled = .Values.workloadAutoscaling.enabled -}}
  {{- end -}}
  {{- printf "%v" $workloadAutoscalingEnabled -}}
{{- end -}}