{{/*
Expand the name of the chart.
*/}}
{{- define "pod-pinner.name" -}}
{{- default "castai-pod-pinner" .Values.global.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pod-pinner.fullname" -}}
{{- if .Values.global.fullnameOverride }}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "castai-pod-pinner" .Values.global.nameOverride }}
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
{{- define "pod-pinner.chart" -}}
{{- printf "%s-%s" "castai-pod-pinner" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pod-pinner.labels" -}}
{{- if gt (len .Values.global.commonLabels) 0 }}
{{- with .Values.global.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
helm.sh/chart: {{ include "pod-pinner.chart" . }}
{{ include "pod-pinner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pod-pinner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pod-pinner.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "pod-pinner.annotations" -}}
{{- if gt (len .Values.global.commonAnnotations) 0 }}
{{- with .Values.global.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use.
This template is used in the child chart, so ensure that it is constructed using the parent's or global values.
*/}}
{{- define "pod-pinner.serviceAccountName" -}}
{{- if .Values.global.serviceAccount.create }}
{{- default (include "pod-pinner.fullname" .) .Values.global.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the webhook to use.
This template is used in the child chart, so ensure that it is constructed using the parent's or global values.
*/}}
{{- define "pod-pinner.webhookName" -}}
{{ include "pod-pinner.fullname" . }}
{{- end }}

{{/*
Construct a label selector that will match the deployment pod selector labels.
*/}}
{{- define "pod-pinner.exludeSelfLabelSelectors" -}}
{{- range splitList "\n" (include "pod-pinner.selectorLabels" .)  }}
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

{{/*
Create the name of the certs secret to use.
This template is used in the child chart, so ensure that it is constructed using the parent's or global values.
*/}}
{{- define "pod-pinner.certsSecretName" -}}
{{ include "pod-pinner.fullname" . }}-certs
{{- end }}

{{/*
Leader's service name.
This template is used in the child chart, so ensure that it is constructed using the parent's or global values.
*/}}
{{- define "pod-pinner.leaderServiceName" -}}
{{- include "pod-pinner.fullname" . }}-leader
{{- end }}

{{/*
Leader election lease name.
This template is used in the child chart, so ensure that it is constructed using the parent's or global values.
*/}}
{{- define "pod-pinner.leaderElectionLeaseName" -}}
{{- include "pod-pinner.fullname" . }}-leader-election
{{- end }}

{{/*
Service account annotations. It's a merge between common annotations and service account annotations.
*/}}
{{- define "pod-pinner.serviceAccountAnnotations" -}}
{{- $saAnnotations := .Values.global.serviceAccount.annotations | default dict }}
{{- $commonAnnotations := .Values.global.commonAnnotations | default dict }}
{{- $mergedAnnotations := merge $saAnnotations $commonAnnotations  }}
{{- if gt (len $mergedAnnotations) 0 }}
{{- with $mergedAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
