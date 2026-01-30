{{/*
Expand the name of the chart.
*/}}
{{- define "vllm.fullname" -}}
{{ .Values.service.name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vllm.chart" -}}
{{- printf "%s-%s" "vllm" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vllm.labels" -}}
helm.sh/chart: {{ include "vllm.chart" . }}
model.aibrix.ai/name: {{ include "vllm.fullname" . }}
{{ include "vllm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vllm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vllm.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{/*
Get the registry secret names, defaulting to the chart's fullname with a proper suffix
Usage: {{ include "modelRegistrySecretName" . }}
*/}}
{{- define "modelRegistrySecretName" -}}
{{- .Values.model.registry.secretName | default (printf "%s-model-registry" (include "vllm.fullname" .)) -}}
{{- end }}

{{- define "loraRegistrySecretName" -}}
{{- .Values.loraAdapter.registry.secretName | default (printf "%s-lora-registry" (include "vllm.fullname" .)) -}}
{{- end }}

{{- define "modelCacheSecretName" -}}
{{- .Values.model.cache.secretName | default (printf "%s-model-cache-registry" (include "vllm.fullname" .)) -}}
{{- end }}

{{/*
Model source credentials (GCS or S3) shared by vLLM and model-downloader.
Emits both the standard cloud SDK envs (GOOGLE_APPLICATION_CREDENTIALS/AWS_*)
for vLLM and the SOURCE_* envs expected by model-downloader.
Usage: {{ include "modelSourceCredentialsEnvVars" . | nindent 12 }}
*/}}
{{- define "modelSourceCredentialsEnvVars" -}}
{{- if eq .Values.model.sourceRegistry "gcs" }}
- name: SOURCE_TYPE
  value: "gcs"
- name: SOURCE_GCS_CREDENTIALS_FILE
  value: "/etc/gcs-credentials/credentials.json"
- name: GOOGLE_APPLICATION_CREDENTIALS
  value: "/etc/gcs-credentials/credentials.json"
{{- else if eq .Values.model.sourceRegistry "s3" }}
- name: SOURCE_TYPE
  value: "s3"
- name: SOURCE_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsAccessKeyId"
      optional: true
- name: SOURCE_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsSecretAccessKey"
      optional: true
- name: SOURCE_S3_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsRegion"
      optional: true
- name: SOURCE_S3_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsEndpointUrl"
      optional: true
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsAccessKeyId"
      optional: true
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsSecretAccessKey"
      optional: true
- name: AWS_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsRegion"
      optional: true
- name: AWS_DEFAULT_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsRegion"
      optional: true
- name: AWS_ENDPOINT_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" . }}
      key: "awsEndpointUrl"
      optional: true
{{- end }}
{{- end }}

{{/*
Model cache bucket credentials (only when cache enabled). Used by vLLM container.
Usage: {{ include "modelCacheCredentialsEnvVars" . | nindent 12 }}
*/}}
{{- define "modelCacheCredentialsEnvVars" -}}
{{- if and .Values.model.cache.enabled (eq .Values.model.cache.bucketType "gcs") }}
- name: CACHE_GOOGLE_APPLICATION_CREDENTIALS
  value: "/etc/cache-gcs-credentials/credentials.json"
{{- end }}
{{- if and .Values.model.cache.enabled (eq .Values.model.cache.bucketType "s3") }}
- name: CACHE_AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsAccessKeyId"
      optional: true
- name: CACHE_AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsSecretAccessKey"
      optional: true
- name: CACHE_AWS_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsRegion"
      optional: true
- name: CACHE_AWS_ENDPOINT_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsEndpointUrl"
      optional: true
{{- end }}
{{- end }}

{{/*
Return the leaf directory name of the model, e.g.
model.name = "castai-llms/llama3.2:1b" -> "llama3.2:1b"
Usage: {{ include "model.dirName" . }}
*/}}
{{- define "model.dirName" -}}
{{- $parts := splitList "/" .Values.model.name -}}
{{- index $parts (sub (len $parts) 1) -}}
{{- end }}

{{/*
Create model reference based on source registry
Usage {{ include "modelReference" . }}
*/}}
{{- define "modelReference" -}}
{{- if eq .Values.model.sourceRegistry "hf" -}}
{{ .Values.model.name }}
{{- else if and .Values.useRunAiStreamer (eq .Values.model.sourceRegistry "gcs") -}}
gs://{{ .Values.model.name }}
{{- else if and .Values.useRunAiStreamer (eq .Values.model.sourceRegistry "s3") -}}
s3://{{ .Values.model.name }}
{{- else -}}
/models/{{ .Values.model.name }}
{{- end -}}
{{- end }}

{{/*
Create LoRA adapter path based on source registry
For HF, vLLM can pull directly from Hugging Face, so we use the repo ID
For GCS/S3, we use the local path where the init container downloads it
Usage {{ include "loraAdapterPath" . }}
*/}}
{{- define "loraAdapterPath" -}}
{{- if eq .Values.loraAdapter.sourceRegistry "hf" -}}
{{ .Values.loraAdapter.name }}
{{- else -}}
/models/{{ .Values.loraAdapter.name }}
{{- end -}}
{{- end }}

{{/*
Generate model downloader's storage environment variables for LoRA registry
Usage: {{ include "loraSourceCredentialsEnvVars" (list "gcs" .) }}
*/}}
{{- define "loraSourceCredentialsEnvVars" -}}
{{- $storageType := index . 0 -}}
{{- $ctx := index . 1 -}}
{{- if eq $storageType "gcs" -}}
- name: SOURCE_TYPE
  value: "gcs"
- name: SOURCE_GCS_CREDENTIALS_FILE
  value: "/etc/gcs-credentials-lora/credentials.json"
{{- else if eq $storageType "s3" -}}
- name: SOURCE_TYPE
  value: "s3"
- name: SOURCE_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsAccessKeyId"
      optional: true
- name: SOURCE_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsSecretAccessKey"
      optional: true
- name: SOURCE_S3_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsRegion"
      optional: true
- name: AWS_DEFAULT_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsRegion"
      optional: true
- name: SOURCE_S3_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsEndpointUrl"
      optional: true
{{- end -}}
{{- end }}

{{/*
Model destination (cache bucket) env vars for model-downloader copy (DESTINATION_*).
Usage: {{ include "modelDestinationEnvVars" . | nindent 12 }}
*/}}
{{- define "modelDestinationEnvVars" -}}
- name: DESTINATION_TYPE
  value: "{{ .Values.model.cache.bucketType }}"
- name: DESTINATION_REMOTE_DIR
  value: "{{ .Values.model.cache.bucket }}"
{{- if eq .Values.model.cache.bucketType "gcs" }}
- name: DESTINATION_GCS_CREDENTIALS_FILE
  value: "/etc/cache-gcs-credentials/credentials.json"
{{- else if eq .Values.model.cache.bucketType "s3" }}
- name: DESTINATION_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsAccessKeyId"
      optional: true
- name: DESTINATION_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsSecretAccessKey"
      optional: true
- name: DESTINATION_S3_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsRegion"
      optional: true
- name: DESTINATION_S3_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsEndpointUrl"
      optional: true
{{- end }}
{{- end }}

{{/*
All env vars for the model-cache-checker init container (checks for .copy.manifest in cache bucket).
Usage: {{ include "modelCacheCheckerEnvVars" . | nindent 12 }}
*/}}
{{- define "modelCacheCheckerEnvVars" -}}
- name: SOURCE_TYPE
  value: "{{ .Values.model.cache.bucketType }}"
{{- if eq .Values.model.cache.bucketType "gcs" }}
- name: SOURCE_GCS_CREDENTIALS_FILE
  value: "/etc/cache-gcs-credentials/credentials.json"
{{- else if eq .Values.model.cache.bucketType "s3" }}
- name: SOURCE_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsAccessKeyId"
      optional: true
- name: SOURCE_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsSecretAccessKey"
      optional: true
- name: SOURCE_S3_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsRegion"
      optional: true
- name: SOURCE_S3_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "modelCacheSecretName" . }}
      key: "awsEndpointUrl"
      optional: true
{{- end }}
- name: SOURCE_REMOTE_DIRS
  value: "{{ .Values.model.cache.bucket }}/{{ include "model.dirName" . }}/.copy.manifest"
- name: DESTINATION_LOCAL_DIR
  value: "/cache-ready"
{{- end }}
