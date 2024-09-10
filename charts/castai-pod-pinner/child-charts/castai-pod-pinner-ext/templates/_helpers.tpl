{{/*
Expand the name of the chart.
We use the parent's name and append "-ext" to it.
*/}}
{{- define "pod-pinner-ext.name" -}}
{{- printf "%s-ext" (include "pod-pinner.name" . | trunc 59 | trimSuffix "-") }}
{{- end }}

{{/*
Create a default fully qualified app name.
We use the parent's fullname and append "-ext" to it.
*/}}
{{- define "pod-pinner-ext.fullname" -}}
{{- printf "%s-ext" (include "pod-pinner.fullname" . | trunc 59 | trimSuffix "-") }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pod-pinner-ext.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pod-pinner-ext.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pod-pinner-ext.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "pod-pinner-ext.labels" -}}
{{- if gt (len .Values.global.commonLabels) 0 }}
{{- with .Values.global.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
helm.sh/chart: {{ include "pod-pinner-ext.chart" . }}
{{ include "pod-pinner-ext.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "pod-pinner-ext.annotations" -}}
{{- include "pod-pinner.annotations" . }}
{{- end }}

{{/*
Service account name "inherited" from the parent chart.
*/}}
{{- define "pod-pinner-ext.serviceAccountName" -}}
{{- include "pod-pinner.serviceAccountName" . }}
{{- end }}

{{/*
Webhook name "inherited" from the parent chart.
*/}}
{{- define "pod-pinner-ext.webhookName" -}}
{{- include "pod-pinner.webhookName" . }}
{{- end }}

{{/*
Certs secret name "inherited" from the parent chart.
*/}}
{{- define "pod-pinner-ext.certsSecretName" -}}
{{- include "pod-pinner.certsSecretName" . }}
{{- end }}

{{/*
Leader's service name "inherited" from the parent chart.
*/}}
{{- define "pod-pinner-ext.leaderServiceName" -}}
{{- include "pod-pinner.leaderServiceName" . }}
{{- end }}

{{/*
Leader election lease name "inherited" from the parent chart.
*/}}
{{- define "pod-pinner-ext.leaderElectionLeaseName" -}}
{{- include "pod-pinner.leaderElectionLeaseName" . }}
{{- end }}
