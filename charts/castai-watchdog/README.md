# castai-watchdog

CAST AI Watchdog

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnvs | list | `[]` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].values[0] | string | `"castai-watchdog"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiUrl | string | `"https://api.cast.ai"` |  |
| castai.clusterID | string | `""` |  |
| castai.configMapRef | string | `""` |  |
| castai.organizationID | string | `""` |  |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using custom CNI's. Defaults to "ClusterFirstWithHostNet" if hostNetwork is true |
| fullnameOverride | string | `"castai-watchdog"` |  |
| gcp.clusterName | string | `""` |  |
| gcp.credentialsJSON | string | `""` |  |
| gcp.location | string | `""` |  |
| gcp.project | string | `""` |  |
| global | object | `{"commonAnnotations":{},"commonLabels":{}}` | Values to apply for the parent and child chart resources. |
| global.commonAnnotations | object | `{}` | Annotations to add to all resources. |
| global.commonLabels | object | `{}` | Labels to add to all resources. |
| hostNetwork | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/watchdog"` |  |
| image.tag | string | `""` |  |
| nameOverride | string | `""` |  |
| podAnnotations | object | `{}` | Annotations added to each pod. |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1005` |  |
| podSecurityContext.runAsGroup | int | `1005` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1005` |  |
| priorityClass.enabled | bool | `true` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| replicas | int | `1` |  |
| resources.limits.memory | string | `"100Mi"` |  |
| resources.requests.cpu | string | `"20m"` |  |
| resources.requests.memory | string | `"100Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| webhook.failurePolicy | string | `"Ignore"` |  |
| webhook.reinvocationPolicy | string | `"Never"` |  |
| webhook.url | string | `""` |  |
