{{/*
Shared credential Secret name.
Returns the user-managed secret name when set (global.apiKeySecretRef or its alias
global.castai.apiKeySecretRef), otherwise "castai-credentials".
*/}}
{{ define "castai-umbrella.credentialsSecretName" -}}
{{- or .Values.global.apiKeySecretRef .Values.global.castai.apiKeySecretRef | default "castai-credentials" -}}
{{- end }}

{{/*
Shared config ConfigMap name.
Sub-charts that support configMapRef should reference this.
*/}}
{{ define "castai-umbrella.configMapName" -}}
castai-agent-metadata
{{- end }}
