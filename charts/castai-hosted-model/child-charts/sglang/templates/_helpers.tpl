{{/*
Expand the name of the chart.
service.name is normally provided by the parent chart's per-model values. Fall
back to a Release-derived name so resources never render with an empty name.
*/}}
{{- define "sglang.fullname" -}}
{{ .Values.service.name | default (printf "%s-sglang" .Release.Name) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Public Service object name — the DNS name clients/gateway resolve.
Defaults to sglang.fullname (the workload identity), but can be overridden with
service.publicName WITHOUT touching sglang.fullname. This decouples the *public
Service name* from the *worker/router Deployment names + selector labels*, so a
model can adopt a stable public name (e.g. front an existing vLLM Service name
during a cutover) WITHOUT renaming — and thus redeploying — the SGLang workers
or router (their selectorLabels are immutable; renaming forces a recreate).
Only the Service metadata.name uses this; selectors still use sglang.fullname.
*/}}
{{- define "sglang.serviceName" -}}
{{ .Values.service.publicName | default (include "sglang.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sglang.chart" -}}
{{- printf "%s-%s" "sglang" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sglang.labels" -}}
helm.sh/chart: {{ include "sglang.chart" . }}
model.aibrix.ai/name: {{ include "sglang.fullname" . }}
{{ include "sglang.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sglang.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sglang.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the HuggingFace token secret.
*/}}
{{- define "sglang.hfSecretName" -}}
{{- printf "%s-model-registry" (include "sglang.fullname" .) -}}
{{- end }}

{{/*
Router name (the worker fullname with a -router suffix).
*/}}
{{- define "sglang.router.fullname" -}}
{{- printf "%s-router" (include "sglang.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Router selector labels — used by the model Service to target the ROUTER pod
(Option A) and by the router Deployment's own selector.
*/}}
{{- define "sglang.router.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sglang.router.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Router common labels.
*/}}
{{- define "sglang.router.labels" -}}
helm.sh/chart: {{ include "sglang.chart" . }}
{{ include "sglang.router.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: router
{{- end }}

{{/*
The label selector string the router passes to --selector for service-discovery.
Defaults to THIS instance's worker selector labels, plus any router.serviceDiscovery.extraSelector.
Rendered as space-separated key=value pairs.
*/}}
{{- define "sglang.router.discoverySelector" -}}
{{- $pairs := list (printf "app.kubernetes.io/name=%s" (include "sglang.fullname" .)) (printf "app.kubernetes.io/instance=%s" .Release.Name) -}}
{{- range $k, $v := .Values.router.serviceDiscovery.extraSelector -}}
{{- $pairs = append $pairs (printf "%s=%s" $k $v) -}}
{{- end -}}
{{- join " " $pairs -}}
{{- end }}
