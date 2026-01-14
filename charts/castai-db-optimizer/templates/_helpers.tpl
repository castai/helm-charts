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

{{- define "queryProcessorImage" -}}
{{-  default (include "defaultQueryProcessorVersion" .) .Values.queryProcessorImage.tag }}
{{- end }}

{{- define "proxyImage" -}}
{{-  default (include "defaultProxyVersion" .) .Values.proxyImage.tag }}
{{- end }}

{{- define "cloudSqlProxyImage" -}}
{{-  default (include "defaultCloudSqlProxyVersion" .) .Values.cloudSqlProxyImage.tag }}
{{- end }}

{{- define "pgdogImage" -}}
{{-  default (include "defaultPgdogVersion" .) .Values.pgdogImage.tag }}
{{- end }}

{{/*
Helpers for customizing proxy TLS settings.
*/}}
{{- define "proxy.tls.certificates" -}}
tls_certificates:
  - certificate_chain:
      filename: "{{ if .Values.proxy.tlsSecretName }}/etc/tls/tls.crt{{ else }}cert.pem{{ end }}"
    private_key:
      filename: "{{ if .Values.proxy.tlsSecretName }}/etc/tls/tls.key{{ else }}key.pem{{ end }}"
{{- end -}}

{{/*
Define common labels.
*/}}
{{- define "labels" -}}
{{- if .Values.commonLabels }}
{{ if gt (len .Values.commonLabels) 0 -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
app.kubernetes.io/managed-by: Helm
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/name: {{ include "name" . }}
helm.sh/chart: {{ include "chart" . }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "annotations" -}}
{{- if .Values.commonAnnotations }}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "selectorLabels" -}}
app.kubernetes.io/name: {{ include "name" . }}
{{- end }}

{{- define "workloads-annotations" -}}
{{- if hasKey .Values "workloadsAnnotations" }}
  {{- if kindIs "map" .Values.workloadsAnnotations }}
    {{- if eq (len .Values.workloadsAnnotations) 0 }}
      {{- /* Empty map, render nothing (disabled) */ -}}
    {{- else }}
      {{- /* Custom annotations provided */ -}}
{{- toYaml .Values.workloadsAnnotations }}
    {{- end }}
  {{- else }}
    {{- /* Null or other non-map value, render default */ -}}
workloads.cast.ai/configuration: |
  vertical:
    memory:
      optimization: off
    containers:
      query-processor:
        cpu:
          min: {{ .Values.resources.queryProcessor.cpu }}
      proxy:
        cpu:
          min: {{ .Values.resources.proxy.cpu }}
  {{- end }}
{{- else }}
  {{- /* Not defined, render default */ -}}
workloads.cast.ai/configuration: |
  vertical:
    memory:
      optimization: off
    containers:
      query-processor:
        cpu:
          min: {{ .Values.resources.queryProcessor.cpu }}
      proxy:
        cpu:
          min: {{ .Values.resources.proxy.cpu }}
{{- end }}
{{- end }}

{{/*
Convert CPU resource limit to concurrency value.
*/}}
{{- define "cpu-to-concurrency" -}}
{{- $cpu := toString . -}}
{{- $cpuCores := 0.0 -}}
{{- if hasSuffix "m" $cpu -}}
  {{- $cpuCores = divf (float64 (trimSuffix "m" $cpu)) 1000.0 -}}
{{- else -}}
  {{- $cpuCores = float64 $cpu -}}
{{- end -}}
{{- int (ceil $cpuCores) -}}
{{- end -}}
