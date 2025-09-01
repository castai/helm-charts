# castai-pod-node-lifecycle

![Version: 0.37.1](https://img.shields.io/badge/Version-0.37.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.31.0](https://img.shields.io/badge/AppVersion-v0.31.0-informational?style=flat-square)

CAST AI spot-only K8s webhook to control workload placement during cluster migration and spot-only.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].values[0] | string | `"castai-pod-node-lifecycle"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| api.clusterId | string | `""` |  |
| api.key | string | `""` |  |
| api.keySecretRef | string | `""` |  |
| api.url | string | `"https://api.cast.ai"` |  |
| deploy | bool | `true` |  |
| dnsConfig | object | `{}` | DNS configuration for the pod ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` |  |
| fullnameOverride | string | `""` |  |
| hostNetwork.enabled | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/pod-node-lifecycle"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| mainContainerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| metrics.enabled | bool | `true` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1005` |  |
| podSecurityContext.runAsGroup | int | `1005` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1005` |  |
| priorityClass.enabled | bool | `true` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| replicaCount | int | `3` |  |
| resources.limits.cpu | string | `"1000m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| staticConfig.cacheTTLSeconds | int | `60` |  |
| staticConfig.defaultToSpot | bool | `true` |  |
| staticConfig.forcePodsToOnDemand | string | `nil` |  |
| staticConfig.forcePodsToSpot | string | `nil` |  |
| staticConfig.ignorePods | string | `nil` |  |
| staticConfig.preset | string | `nil` |  |
| staticConfig.presets.allSpot | string | `"defaultToSpot: true\nspotPercentageOfReplicaSet: 0\nignorePods: []\nforcePodsToSpot: []\nforcePodsToOnDemand: []\n"` |  |
| staticConfig.presets.allSpotExceptKubeSystem | string | `"defaultToSpot: true\nspotPercentageOfReplicaSet: 0\nignorePods: []\nforcePodsToSpot: []\nforcePodsToOnDemand:\n  - namespaces:\n      - kube-system\n"` |  |
| staticConfig.presets.partialSpot | string | `"defaultToSpot: true\nspotPercentageOfReplicaSet: 40\nignorePods: []\nforcePodsToSpot: []\nforcePodsToOnDemand: []\n"` |  |
| staticConfig.spotPercentageOfReplicaSet | int | `0` |  |
| staticConfig.stringTemplate | string | `"defaultToSpot: {{ .Values.staticConfig.defaultToSpot }}\nspotPercentageOfReplicaSet: {{ .Values.staticConfig.spotPercentageOfReplicaSet }}\n{{- if .Values.staticConfig.IgnorePodsWithNodeSelectorsAffinities }}\nIgnorePodsWithNodeSelectorsAffinities: {{ .Values.staticConfig.IgnorePodsWithNodeSelectorsAffinities }}\n{{- end }}\n{{- if .Values.staticConfig.ignorePods }}\nignorePods:\n{{ toYaml .Values.staticConfig.ignorePods }}\n{{- end }}\n{{- if .Values.staticConfig.forcePodsToSpot }}\nforcePodsToSpot:\n{{ toYaml .Values.staticConfig.forcePodsToSpot }}\n{{- end }}\n{{- if .Values.staticConfig.forcePodsToOnDemand }}\nforcePodsToOnDemand:\n{{ toYaml .Values.staticConfig.forcePodsToOnDemand }}\n{{- end }}\n{{- if .Values.staticConfig.cacheTTLSeconds }}\ncacheTTLSeconds: {{ toYaml .Values.staticConfig.cacheTTLSeconds }}\n{{- end }}\n"` |  |
| telemetry.enabled | bool | `false` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| webhook.failurePolicy | string | `""` |  |
| webhook.port | int | `10250` |  |
| webhook.url | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
