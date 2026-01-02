{{/*
Expand the name of the chart.
*/}}
{{- define "cluster-controller-ext.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cluster-controller-ext.fullname" -}}
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
{{- define "cluster-controller-ext.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cluster-controller-ext.labels" -}}
{{- with .Values.global }}
{{- with .commonLabels }}
{{- toYaml . }}
{{ end }}
{{- end }}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{ end }}
helm.sh/chart: {{ include "cluster-controller-ext.chart" . }}
{{ include "cluster-controller-ext.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "cluster-controller-ext.annotations" -}}
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
{{- define "cluster-controller-ext.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster-controller-ext.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
