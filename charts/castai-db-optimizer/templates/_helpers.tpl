{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define common labels.
*/}}
{{- define "labels" -}}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ include "chart" . }}
{{- end }}


{{- define "extractUrlComponents" -}}
  {{- $url := . -}}
  {{- $protocol := "unknown" -}}
  {{- $host := "" -}}
  {{- $port := "" -}}
  {{- $tls := false -}}

  {{- if hasPrefix "https://" $url -}}
    {{- $protocol = "https" -}}
    {{- $url = trimPrefix "https://" $url -}}
    {{- $port = 443 -}}
    {{- $tls = true -}}
  {{- else if hasPrefix "http://" $url -}}
    {{- $protocol = "http" -}}
    {{- $url = trimPrefix "http://" $url -}}
    {{- $port = 80 -}}
  {{- end -}}

  {{- $urlParts := split ":" $url -}}
  {{- $host = index $urlParts "_0" -}}

  {{- if gt (len $urlParts) 1 -}}
    {{- $port = index $urlParts "_1" -}}
  {{- end -}}

  {{- $result := dict "url" . "protocol" $protocol "host" $host "port" $port "tls" $tls -}}
  {{ $result | toYaml}}
{{- end -}}