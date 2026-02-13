{{/*
Shared credential Secret name.
All sub-charts that support apiKeySecretRef should reference this.
*/}}
{{ define "castai-kent.credentialsSecretName" -}}
castai-credentials
{{- end }}

{{/*
Shared config ConfigMap name.
Sub-charts that support configMapRef should reference this.
*/}}
{{ define "castai-kent.configMapName" -}}
castai-agent-metadata
{{- end }}
