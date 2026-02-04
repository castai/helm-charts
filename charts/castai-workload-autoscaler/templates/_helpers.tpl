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

{{/*
Detect if running on GKE Autopilot
Checks for Autopilot-specific resources in the cluster
*/}}
{{- define "workload-autoscaler.isAutopilot" -}}
{{- if .Values.autopilot.enabled -}}
true
{{- else if .Values.autopilot.autoDetect -}}
  {{- /* Check for Warden validating webhook (Autopilot-specific) */ -}}
  {{- $wardenWebhook := lookup "admissionregistration.k8s.io/v1" "ValidatingWebhookConfiguration" "" "warden-validating.config.common-webhooks.networking.gke.io" -}}
  {{- if $wardenWebhook -}}
true
  {{- else -}}
    {{- /* Fallback: check first node for gke-provisioning label (performance optimization) */ -}}
    {{- $nodes := lookup "v1" "Node" "" "" -}}
    {{- if $nodes -}}
      {{- if $nodes.items -}}
        {{- if gt (len $nodes.items) 0 -}}
          {{- if hasKey (index $nodes.items 0).metadata.labels "cloud.google.com/gke-provisioning" -}}
true
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Enforce minimum CPU value for Autopilot
Takes a CPU value string and returns it unchanged or 500m minimum if on Autopilot
Usage: include "workload-autoscaler.enforceCPUMinimum" (dict "cpu" .Values.resources.requests.cpu "context" .)
*/}}
{{- define "workload-autoscaler.enforceCPUMinimum" -}}
{{- $isAutopilot := eq (include "workload-autoscaler.isAutopilot" .context) "true" -}}
{{- $cpuValue := .cpu | toString -}}
{{- if $isAutopilot -}}
  {{- /* On Autopilot, enforce minimum 500m CPU */ -}}
  {{- $cpuMillicores := 0 -}}
  {{- if hasSuffix "m" $cpuValue -}}
    {{- $cpuMillicores = trimSuffix "m" $cpuValue | int -}}
  {{- else -}}
    {{- /* Convert cores to millicores (e.g., "1" -> 1000, "0.5" -> 500) */ -}}
    {{- $cpuMillicores = mulf ($cpuValue | float64) 1000.0 | int -}}
  {{- end -}}
  {{- if lt $cpuMillicores 500 -}}
500m
  {{- else if hasSuffix "m" $cpuValue -}}
{{ $cpuValue }}
  {{- else -}}
{{ printf "%dm" $cpuMillicores }}
  {{- end -}}
{{- else -}}
{{ $cpuValue }}
{{- end -}}
{{- end -}}

{{/*
Get CPU request based on Autopilot detection
Autopilot requires minimum 500m CPU when using pod anti-affinity
*/}}
{{- define "workload-autoscaler.resources.requests.cpu" -}}
{{- if not .Values.resources.requests.cpu -}}
  {{- fail "resources.requests.cpu is required but not set" -}}
{{- end -}}
{{- include "workload-autoscaler.enforceCPUMinimum" (dict "cpu" .Values.resources.requests.cpu "context" .) -}}
{{- end -}}

{{/*
Get CPU limit based on Autopilot detection
Autopilot requires minimum 500m CPU when using pod anti-affinity
*/}}
{{- define "workload-autoscaler.resources.limits.cpu" -}}
{{- if not .Values.resources.limits.cpu -}}
  {{- /* No CPU limit set, return empty */ -}}
{{- else -}}
{{- include "workload-autoscaler.enforceCPUMinimum" (dict "cpu" .Values.resources.limits.cpu "context" .) -}}
{{- end -}}
{{- end -}}