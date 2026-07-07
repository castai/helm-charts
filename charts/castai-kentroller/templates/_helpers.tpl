{{/*
Resolve image repository: prepend global.registry if set.
*/}}
{{- define "castai-kentroller.imageRepository" -}}
{{- $repository := required "image.repository must be provided" .Values.image.repository -}}
{{- $registry := ((.Values.global | default dict).registry) | default "" -}}
{{- if $registry -}}
{{- printf "%s/%s" (trimSuffix "/" $registry) $repository -}}
{{- else -}}
{{- $repository -}}
{{- end -}}
{{- end }}

{{/*
Resolve imagePullSecrets: merge global.imagePullSecrets with local imagePullSecrets.
*/}}
{{- define "castai-kentroller.imagePullSecrets" -}}
{{- $global := .Values.global | default dict -}}
{{- $combined := concat ($global.imagePullSecrets | default list) (.Values.imagePullSecrets | default list) -}}
{{- if $combined -}}
{{ toYaml $combined }}
{{- end -}}
{{- end }}

{{/*
Merge global and chart-level tolerations.
*/}}
{{- define "castai-kentroller.tolerations" -}}
{{- $global := .Values.global | default dict -}}
{{- with concat ($global.tolerations | default list) (.Values.tolerations | default list) -}}
{{ toYaml . }}
{{- end -}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "castai-kentroller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "castai-kentroller.fullname" -}}
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
{{- define "castai-kentroller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "castai-kentroller.labels" -}}
helm.sh/chart: {{ include "castai-kentroller.chart" . }}
{{ include "castai-kentroller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "castai-kentroller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "castai-kentroller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "castai-kentroller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "castai-kentroller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the dynamic configmap
*/}}
{{- define "castai-kentroller.dynamicConfigMapName" -}}
{{- printf "%s-dynamic-config" (include "castai-kentroller.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the Secret that holds the webhook serving certificate.
Managed by the in-process cert-controller (rotator); never mounted into the
pod, only used as the rendezvous point so all kentroller replicas converge
on the same CA across restarts.
*/}}
{{- define "castai-kentroller.webhookCertsSecretName" -}}
{{- default (printf "%s-webhook-certs" (include "castai-kentroller.fullname" .)) .Values.webhook.certsSecretName }}
{{- end }}

{{/*
Name of the MutatingWebhookConfiguration object. The cert-rotator patches
the caBundle on this object on every rotation.
*/}}
{{- define "castai-kentroller.webhookConfigurationName" -}}
{{- printf "%s-pod-tsc" (include "castai-kentroller.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the Service in front of the webhook server.
*/}}
{{- define "castai-kentroller.webhookServiceName" -}}
{{- printf "%s-webhook" (include "castai-kentroller.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
