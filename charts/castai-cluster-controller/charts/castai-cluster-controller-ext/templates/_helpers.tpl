{{/*
Expand the name of the chart.
*/}}
{{- define "castai-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "castai-agent.labels" -}}
{{ if gt (len .Values.commonLabels) 0 -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{ include "castai-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "castai-agent.annotations" -}}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "castai-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
