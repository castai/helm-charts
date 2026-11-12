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

{{/*
Resolve image.repository, prepending global.registry when the CAST AI
umbrella chart provides one.
*/}}
{{- define "castai-storage-autoscaler.imageRepository" -}}
{{- $repository := required "image.repository must be provided" .Values.image.repository -}}
{{- $registry := ((.Values.global | default dict).registry) | default "" -}}
{{- if $registry -}}
{{- printf "%s/%s" (trimSuffix "/" $registry) $repository -}}
{{- else -}}
{{- $repository -}}
{{- end -}}
{{- end }}

{{/*
Resolve migration.workerImage: prepends global.registry to the repository
when set; an empty tag falls back to .Chart.AppVersion.
*/}}
{{- define "castai-storage-autoscaler.workerPodImage" -}}
{{- if .Values.migration.rsyncWorkerPodImage -}}
{{- fail "migration.rsyncWorkerPodImage was removed: use migration.workerImage.repository and migration.workerImage.tag" -}}
{{- end -}}
{{- $repository := required "migration.workerImage.repository must be provided" .Values.migration.workerImage.repository -}}
{{- $registry := ((.Values.global | default dict).registry) | default "" -}}
{{- if $registry -}}
{{- $repository = printf "%s/%s" (trimSuffix "/" $registry) $repository -}}
{{- end -}}
{{- printf "%s:%s" $repository (.Values.migration.workerImage.tag | default .Chart.AppVersion) -}}
{{- end }}

{{/*
Resolve imagePullSecrets: merge global.imagePullSecrets with image.pullSecrets.
*/}}
{{- define "castai-storage-autoscaler.imagePullSecrets" -}}
{{- $global := .Values.global | default dict -}}
{{- $combined := concat ($global.imagePullSecrets | default list) (.Values.image.pullSecrets | default list) -}}
{{- if $combined -}}
{{ toYaml $combined }}
{{- end -}}
{{- end }}

{{/*
Merge global.tolerations with a chart-local tolerations list.
*/}}
{{- define "castai-storage-autoscaler.tolerations" -}}
{{- $global := .global | default dict -}}
{{- with concat ($global.tolerations | default list) (.local | default list) -}}
{{ toYaml . }}
{{- end -}}
{{- end }}

{{/*
Resolve the CAST AI API URL: an umbrella-provided global.castai.apiURL wins
over the chart-local default.
*/}}
{{- define "castai-storage-autoscaler.apiURL" -}}
{{- coalesce (dig "castai" "apiURL" "" (.Values.global | default dict)) .Values.castai.apiURL -}}
{{- end }}

{{/*
Resolve the API_KEY secretKeyRef: chart-local castai.apiKeySecretRef wins, then
the umbrella global.castai.apiKeySecretRef (name only), then the chart-managed
castai-api-key Secret.
*/}}
{{- define "castai-storage-autoscaler.apiKeySecretRef" -}}
{{- if and .Values.castai.apiKeySecretRef .Values.castai.apiKeySecretRef.name -}}
name: {{ .Values.castai.apiKeySecretRef.name }}
key: {{ .Values.castai.apiKeySecretRef.key | default "API_KEY" }}
{{- else if dig "castai" "apiKeySecretRef" "" (.Values.global | default dict) -}}
name: {{ dig "castai" "apiKeySecretRef" "" (.Values.global | default dict) }}
key: API_KEY
{{- else -}}
name: castai-api-key
key: API_KEY
{{- end }}
{{- end }}

{{- define "castai-storage-autoscaler.validateCastai" -}}
{{- if and .Values.castai .Values.castai.enabled -}}
  {{- $globalApiKeyRef := dig "castai" "apiKeySecretRef" "" (.Values.global | default dict) -}}
  {{- if and (not (and .Values.castai.clusterIDConfigMapRef .Values.castai.clusterIDConfigMapRef.name)) (not .Values.castai.clusterID) -}}
    {{- fail "castai.clusterID or castai.clusterIDConfigMapRef.name is required when castai.enabled=true" -}}
  {{- end -}}
  {{- if and (not .Values.castai.apiKey) (not (and .Values.castai.apiKeySecretRef .Values.castai.apiKeySecretRef.name)) (not $globalApiKeyRef) -}}
    {{- fail "castai.apiKey, castai.apiKeySecretRef or the umbrella's global.castai.apiKeySecretRef must be provided when castai.enabled=true" -}}
  {{- end -}}
  {{- if and .Values.config.policySync.enabled -}}
    {{- if and (not (and .Values.castai.orgIDConfigMapRef .Values.castai.orgIDConfigMapRef.name)) (not .Values.castai.organizationID) -}}
      {{- fail "castai.organizationID or castai.orgIDConfigMapRef.name is required when config.policySync.enabled=true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "castai-storage-autoscaler.validateWorkerAuth" -}}
{{- if and .Values.migration.enabled .Values.migration.workerAuth.enabled -}}
  {{- $token := .Values.migration.workerAuth.token | default "" -}}
  {{- $refName := "" -}}
  {{- if .Values.migration.workerAuth.tokenSecretRef -}}
    {{- $refName = .Values.migration.workerAuth.tokenSecretRef.name | default "" -}}
  {{- end -}}
  {{- if and $token $refName -}}
    {{- fail "migration.workerAuth: set either token or tokenSecretRef.name, not both" -}}
  {{- end -}}
  {{- if and (not $token) (not $refName) -}}
    {{- fail "migration.workerAuth: provide tokenSecretRef.name (recommended, GitOps-safe) or token (inline); create the secret with: kubectl -n <release-namespace> create secret generic castai-storage-autoscaler-migration-worker-token --from-literal=worker-token=$(openssl rand -hex 32); or set migration.workerAuth.enabled=false to run without worker auth" -}}
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
