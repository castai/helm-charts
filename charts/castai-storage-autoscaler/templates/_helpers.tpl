{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "castai-storage-autoscaler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "castai-storage-autoscaler.fullname" -}}
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
Common labels
*/}}

{{- define "castai-storage-autoscaler.commonLabels" -}}
{{- range $key, $value := .Values.commonLabels }}
{{$key}}: {{$value}}
{{- end }}
{{- end }}

{{- define "castai-storage-autoscaler.labels" -}}
helm.sh/chart: {{ include "castai-storage-autoscaler.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "castai-storage-autoscaler.selectorLabels" . }}
{{- end }}

{{- define "castai-storage-autoscaler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-storage-autoscaler.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: controller
{{- end }}

{{- define "castai-storage-autoscaler.webhookSelectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-storage-autoscaler.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: webhook
{{- end }}

{{- define "castai-storage-autoscaler.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "castai-storage-autoscaler.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Convert a map[string]string to envconfig map format: "key1:val1,key2:val2"
*/}}
{{- define "castai-storage-autoscaler.labelsToEnv" -}}
{{- $pairs := list -}}
{{- range $k, $v := . -}}
{{- $pairs = append $pairs (printf "%s:%s" $k $v) -}}
{{- end -}}
{{- join "," $pairs -}}
{{- end -}}

{{- define "castai-storage-autoscaler.validateCastai" -}}
{{- if and .Values.castai .Values.castai.enabled -}}
  {{- if and (not (and .Values.castai.clusterIDConfigMapRef .Values.castai.clusterIDConfigMapRef.name)) (not .Values.castai.clusterID) -}}
    {{- fail "castai.clusterID or castai.clusterIDConfigMapRef.name is required when castai.enabled=true" -}}
  {{- end -}}
  {{- if and (not .Values.castai.apiKey) (not (and .Values.castai.apiKeySecretRef .Values.castai.apiKeySecretRef.name)) -}}
    {{- fail "castai.apiKey or castai.apiKeySecretRef must be provided when castai.enabled=true" -}}
  {{- end -}}
  {{- if and .Values.config.policySync.enabled -}}
    {{- if and (not (and .Values.castai.orgIDConfigMapRef .Values.castai.orgIDConfigMapRef.name)) (not .Values.castai.organizationID) -}}
      {{- fail "castai.organizationID or castai.orgIDConfigMapRef.name is required when config.policySync.enabled=true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*https://github.com/kubernetes/kubernetes/issues/91514#issuecomment-2209311103*/}}
{{- define "GOMEMLIMITEnv" -}}
{{- $memory := . -}}
{{- if $memory -}}
- name: GOMEMLIMIT
  {{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
  {{- $unit := regexFind "[A-Za-z]+" $memory -}}
  {{- $valueMi := 0.0 -}}
  {{- if eq $unit "Gi" -}}
    {{- $valueMi = mulf $value 1024 -}}
  {{- else if eq $unit "Mi" -}}
    {{- $valueMi = $value -}}
  {{- end -}}
  {{- $percentageValue := int (mulf $valueMi 0.9) }}
  value: {{ printf "%dMiB" $percentageValue -}}
{{- end -}}
{{- end -}}
