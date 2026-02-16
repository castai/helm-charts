{{/*
Shared credential Secret name.
All sub-charts that support apiKeySecretRef should reference this.
*/}}
{{ define "castai-umbrella.credentialsSecretName" -}}
castai-credentials
{{- end }}

{{/*
Shared config ConfigMap name.
Sub-charts that support configMapRef should reference this.
*/}}
{{ define "castai-umbrella.configMapName" -}}
castai-agent-metadata
{{- end }}
