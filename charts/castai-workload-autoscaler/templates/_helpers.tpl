{{/*
Expand the name of the chart.
*/}}
{{- define "workload-autoscaler.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "workload-autoscaler.fullname" -}}
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
{{- define "workload-autoscaler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "workload-autoscaler.labels" -}}
helm.sh/chart: {{ include "workload-autoscaler.chart" . }}
{{ include "workload-autoscaler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Test labels
*/}}
{{- define "workload-autoscaler.testLabels" -}}
{{- $labels := include "workload-autoscaler.labels" . | fromYaml -}}
# Override name to avoid podAntiAffinity
{{- $labels = merge (dict "app.kubernetes.io/name" "castai-workload-autoscaler-test") $labels -}}
{{- toYaml $labels -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "workload-autoscaler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "workload-autoscaler.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "workload-autoscaler.annotations" -}}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{- define "workload-autoscaler.webhookName" -}}
{{ include "workload-autoscaler.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "workload-autoscaler.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "workload-autoscaler.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "workload-autoscaler.exludeSelfLabelSelectors" -}}
{{- range splitList "\n" (include "workload-autoscaler.selectorLabels" .)  }}
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

{{- define "workload-autoscaler.leaderElectionLeaseName" -}}
{{- if and .Values.leaderElection .Values.leaderElection.leaseName }}
{{- quote .Values.leaderElection.leaseName }}
{{- else }}
{{- quote "castai-workload-autoscaler" -}}
{{- end }}
{{- end }}

{{- define "workload-autoscaler.certsSecretName" -}}
{{ include "workload-autoscaler.fullname" . }}-certs
{{- end }}