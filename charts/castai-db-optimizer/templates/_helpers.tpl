{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "castai-db-optimizer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "castai-db-optimizer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "castai-db-optimizer.queryProcessorImage" -}}
{{-  default (include "castai-db-optimizer.defaultQueryProcessorVersion" .) .Values.queryProcessorImage.tag }}
{{- end }}

{{- define "castai-db-optimizer.proxyImage" -}}
{{-  default (include "castai-db-optimizer.defaultProxyVersion" .) .Values.proxyImage.tag }}
{{- end }}

{{- define "castai-db-optimizer.cloudSqlProxyImage" -}}
{{-  default (include "castai-db-optimizer.defaultCloudSqlProxyVersion" .) .Values.cloudSqlProxyImage.tag }}
{{- end }}

{{- define "castai-db-optimizer.pgdogImage" -}}
{{-  default (include "castai-db-optimizer.defaultPgdogVersion" .) .Values.pgdogImage.tag }}
{{- end }}

{{- define "castai-db-optimizer.proxySqlImage" -}}
{{-  default (include "castai-db-optimizer.defaultProxySqlVersion" .) .Values.proxySqlImage.tag }}
{{- end }}

{{/*
Helpers for customizing proxy TLS settings.
*/}}
{{- define "castai-db-optimizer.proxy.tls.certificates" -}}
tls_certificates:
  - certificate_chain:
      filename: "{{ if .Values.proxy.tlsSecretName }}/etc/tls/tls.crt{{ else }}cert.pem{{ end }}"
    private_key:
      filename: "{{ if .Values.proxy.tlsSecretName }}/etc/tls/tls.key{{ else }}key.pem{{ end }}"
{{- end -}}

{{/*
How long other sidecars should wait for proxy to fully drain before terminating.
*/}}
{{- define "castai-db-optimizer.proxy.draining.sidecarTerminationDelay" -}}
{{- add .Values.proxy.draining.gracePeriodSeconds 15 -}}
{{- end -}}

{{/*
Helper for calculating terminationGracePeriodSeconds
*/}}
{{- define "castai-db-optimizer.terminationGracePeriodSeconds" -}}
{{- if .Values.proxy.draining.enabled -}}
  {{- $grace := add (include "castai-db-optimizer.proxy.draining.sidecarTerminationDelay" .) 15 | int -}}
  {{- if and .Values.pgdog .Values.pgdog.enabled -}}
    {{- add $grace (div .Values.pgdog.config.shutdown_timeout 1000) -}}
  {{- else if and .Values.proxySql .Values.proxySql.enabled -}}
    {{- add $grace 30 -}}
  {{- else -}}
    {{- $grace -}}
  {{- end -}}
{{- else -}}
60
{{- end -}}
{{- end -}}

{{/*
Define common labels.
*/}}
{{- define "castai-db-optimizer.labels" -}}
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
app.kubernetes.io/name: {{ include "castai-db-optimizer.name" . }}
helm.sh/chart: {{ include "castai-db-optimizer.chart" . }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "castai-db-optimizer.annotations" -}}
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
{{- define "castai-db-optimizer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-optimizer.name" . }}
{{- end }}

{{- define "castai-db-optimizer.workloads-annotations" -}}
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
{{- define "castai-db-optimizer.cpu-to-concurrency" -}}
{{- $cpu := toString . -}}
{{- $cpuCores := 0.0 -}}
{{- if hasSuffix "m" $cpu -}}
  {{- $cpuCores = divf (float64 (trimSuffix "m" $cpu)) 1000.0 -}}
{{- else -}}
  {{- $cpuCores = float64 $cpu -}}
{{- end -}}
{{- int (ceil $cpuCores) -}}
{{- end -}}
