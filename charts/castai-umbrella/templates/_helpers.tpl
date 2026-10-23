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

{{/*
Chart name and version as used by the helm.sh/chart label.
*/}}
{{ define "castai-umbrella.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{ define "castai-umbrella.enabledTags" -}}
{{- $tags := .Values.tags | default dict -}}
{{- $enabled := list -}}
{{- range sortAlpha (keys $tags) -}}
{{- if index $tags . }}{{- $enabled = append $enabled . }}{{- end -}}
{{- end -}}
{{- join "," $enabled -}}
{{- end -}}
