{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "castai-db-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "castai-db-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define common labels.
*/}}
{{- define "castai-db-proxy.labels" -}}
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
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
helm.sh/chart: {{ include "castai-db-proxy.chart" . }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "castai-db-proxy.annotations" -}}
{{- if .Values.commonAnnotations }}
{{ if gt (len .Values.commonAnnotations) 0 -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "castai-db-proxy.proxyImage" -}}
{{- default (include "castai-db-proxy.defaultProxyVersion" .) .Values.image.tag }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "castai-db-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
{{- end }}

{{- define "castai-db-proxy.proxySelectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
app.kubernetes.io/component: proxy
{{- end }}

{{- define "castai-db-proxy.poolingSelectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-db-proxy.name" . }}
app.kubernetes.io/component: pooling
{{- end }}

{{- define "castai-db-proxy.poolingConfigManagerImage" -}}
{{- default (include "castai-db-proxy.defaultPoolingConfigManagerVersion" .) .Values.pooling.configManager.image.tag }}
{{- end }}

{{- define "castai-db-proxy.pgdogImage" -}}
{{- default (include "castai-db-proxy.defaultPgdogVersion" .) .Values.pooling.pgdog.image.tag }}
{{- end }}

{{/*
Worker threads for each proxy listener that serves traffic.

An explicit .Values.serverThreads wins; otherwise derive from the CPU request rounded
up, with a floor of 1. Accepts both core ("2") and millicore ("1500m") notation.
One worker per core matches the tokio runtime pingora builds on, which defaults to
one worker thread per available core.
*/}}
{{- define "castai-db-proxy.workerThreads" -}}
{{- if .Values.serverThreads -}}
{{- .Values.serverThreads | int -}}
{{- else -}}
{{- $cpu := .Values.resources.cpu | toString -}}
{{- $cores := 0.0 -}}
{{- if hasSuffix "m" $cpu -}}
{{- $cores = divf (float64 (trimSuffix "m" $cpu)) 1000.0 -}}
{{- else -}}
{{- $cores = float64 $cpu -}}
{{- end -}}
{{- max 1 (int (ceil $cores)) -}}
{{- end -}}
{{- end -}}

{{- define "castai-db-proxy.proxySqlImage" -}}
{{- default (include "castai-db-proxy.defaultProxySqlVersion" .) .Values.pooling.proxySql.image.tag }}
{{- end }}

{{/*
Name of the dedicated read-only service fronting the proxy. The base name is
truncated to 60 characters before appending the "-ro" suffix so the final
name never exceeds the 63-character DNS limit and can never collide with
the main service name after truncation (60 + 3 = 63).
*/}}
{{- define "castai-db-proxy.readonlyName" -}}
{{- printf "%s-ro" (include "castai-db-proxy.name" . | trunc 60 | trimSuffix "-") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the headless service used for cluster peer discovery. The base name
is truncated to 54 characters (63 minus the "headless-" prefix) before the
prefix is prepended so the service name never exceeds the 63-character DNS
label limit. Base names of up to 54 characters render unchanged.
*/}}
{{- define "castai-db-proxy.headlessName" -}}
{{- printf "headless-%s" (include "castai-db-proxy.name" . | trunc 54 | trimSuffix "-") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the headless service fronting the pooling config managers. The base
name is truncated to 47 characters (63 minus "headless-" and "-pooler") so
the service name never exceeds the 63-character DNS label limit. Base names
of up to 47 characters render unchanged.
*/}}
{{- define "castai-db-proxy.poolerHeadlessName" -}}
{{- printf "headless-%s-pooler" (include "castai-db-proxy.name" . | trunc 47 | trimSuffix "-") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Client-facing port exposed by the proxy services. Each dedicated service
(read-write and read-only) exposes the database protocol's default port so
clients can connect without a custom port; the proxy's listen port is only
the service's targetPort.
*/}}
{{- define "castai-db-proxy.servicePort" -}}
{{- $protocol := lower .Values.protocol -}}
{{- if eq $protocol "mysql" -}}
{{- 3306 -}}
{{- else if eq $protocol "postgresql" -}}
{{- 5432 -}}
{{- else if eq $protocol "oracle" -}}
{{- 1521 -}}
{{- else -}}
{{- fail (printf "unsupported protocol %q: must be one of PostgreSQL, MySQL, Oracle" .Values.protocol) -}}
{{- end -}}
{{- end -}}

{{/*
Whether a read-only upstream is configured for the proxy: at least one
endpoint with readonly=true. Pgdog pooling (PostgreSQL) never qualifies —
db-proxy resolves the pgdog sidecar as its only (read-write) endpoint in
that mode, so a read-only address must not be advertised.
*/}}
{{- define "castai-db-proxy.readonlyUpstream" -}}
{{- $pgdogEnabled := and .Values.pooling.enabled (eq .Values.protocol "PostgreSQL") -}}
{{- if $pgdogEnabled -}}
{{- false -}}
{{- else -}}
{{- $hasReadonly := false -}}
{{- range .Values.endpoints -}}
{{- if .readonly -}}
{{- $hasReadonly = true -}}
{{- end -}}
{{- end -}}
{{- $hasReadonly -}}
{{- end -}}
{{- end -}}
