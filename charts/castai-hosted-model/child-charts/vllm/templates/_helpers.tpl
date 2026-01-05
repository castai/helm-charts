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
Generate model downloader's storage environment variables for model registry
Usage: {{ include "modelDownloader.modelEnvVars" (list "gcs" .) }}
*/}}
{{- define "modelDownloader.modelEnvVars" -}}
{{- $storageType := index . 0 -}}
{{- $ctx := index . 1 -}}
{{- if eq $storageType "gcs" -}}
- name: STORAGE_TYPE
  value: "gcs"
- name: GCS_CREDENTIALS_FILE
  value: "/etc/gcs-credentials-model/credentials.json"
{{- else if eq $storageType "s3" -}}
- name: STORAGE_TYPE
  value: "s3"
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" $ctx }}
      key: "awsAccessKeyId"
      optional: true
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" $ctx }}
      key: "awsSecretAccessKey"
      optional: true
- name: AWS_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" $ctx }}
      key: "awsRegion"
      optional: true
- name: AWS_DEFAULT_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" $ctx }}
      key: "awsRegion"
      optional: true
- name: AWS_ENDPOINT_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "modelRegistrySecretName" $ctx }}
      key: "awsEndpointUrl"
      optional: true
{{- end -}}
{{- end }}

{{/*
Generate model downloader's storage environment variables for LoRA registry
Usage: {{ include "modelDownloader.loraEnvVars" (list "gcs" .) }}
*/}}
{{- define "modelDownloader.loraEnvVars" -}}
{{- $storageType := index . 0 -}}
{{- $ctx := index . 1 -}}
{{- if eq $storageType "gcs" -}}
- name: STORAGE_TYPE
  value: "gcs"
- name: GCS_CREDENTIALS_FILE
  value: "/etc/gcs-credentials-lora/credentials.json"
{{- else if eq $storageType "s3" -}}
- name: STORAGE_TYPE
  value: "s3"
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsAccessKeyId"
      optional: true
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsSecretAccessKey"
      optional: true
- name: AWS_REGION
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
- name: AWS_ENDPOINT_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "loraRegistrySecretName" $ctx }}
      key: "awsEndpointUrl"
      optional: true
{{- end -}}
{{- end }}

{{/*
Generate model downloader's volume mounts based on source registry type
Usage: {{ include "modelDownloader.sourceRegistryVolumeMounts" "gcs" }}
*/}}
{{- define "modelDownloader.sourceRegistryVolumeMounts" -}}
{{- $storageType := . -}}
{{- if eq $storageType "gcs" -}}
- name: gcs-credentials-lora
  mountPath: /etc/gcs-credentials
  readOnly: true
{{- end -}}
{{- end }}

{{/*
Generate comma-separated list of model directories
Usage: {{ include "modelDownloader.remoteSourceDirs" . }}
*/}}
{{- define "modelDownloader.remoteSourceDirs" -}}
{{- $dirs := list -}}
{{- if .Values.loraAdapter.name -}}
  {{- $dirs = append $dirs .Values.loraAdapter.name -}}
{{- end -}}
{{- if and (ne .Values.model.sourceRegistry "hf") (not .Values.useRunAiStreamer) -}}
  {{- $dirs = append $dirs .Values.model.name -}}
{{- end -}}
{{- join "," $dirs -}}
{{- end }}
