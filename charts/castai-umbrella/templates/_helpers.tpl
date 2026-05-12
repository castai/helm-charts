{{/*
Shared credential Secret name.
Returns global.castai.apiKeySecretRef when set (user-managed secret), otherwise "castai-credentials".
*/}}
{{ define "castai-umbrella.credentialsSecretName" -}}
{{- if .Values.global.castai.apiKeySecretRef -}}
{{ .Values.global.castai.apiKeySecretRef }}
{{- else -}}
castai-credentials
{{- end -}}
{{- end }}

{{/*
Shared config ConfigMap name.
Sub-charts that support configMapRef should reference this.
*/}}
{{ define "castai-umbrella.configMapName" -}}
castai-agent-metadata
{{- end }}
