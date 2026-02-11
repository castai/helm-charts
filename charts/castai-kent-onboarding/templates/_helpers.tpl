{{/*
Shared credential Secret name.
All sub-charts that support apiKeySecretRef should reference this.
*/}}
{{ define "castai-kent-onboarding.credentialsSecretName" -}}
castai-credentials
{{- end }}

{{/*
Shared config ConfigMap name.
Sub-charts that support configMapRef should reference this.
*/}}
{{ define "castai-kent-onboarding.configMapName" -}}
castai-agent-metadata
{{- end }}
