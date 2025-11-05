# castai-pod-mutator

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.0](https://img.shields.io/badge/AppVersion-v0.1.0-informational?style=flat-square)

CAST AI Pod Mutator.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set additional environment variables for the pod-mutator container. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].values[0] | string | `"castai-pod-mutator"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiUrl | string | `"https://api.cast.ai"` |  |
| castai.clusterID | string | `""` |  |
| castai.clusterIdSecretKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai.clusterIdSecretKeyRef.name | string | `""` |  |
| castai.configMapRef | string | `""` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| dependencyCheck.enabled | bool | `true` | Enable or disable dependency check preinstall hook |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using custom CNI's. Defaults to "ClusterFirstWithHostNet" if hostNetwork is true |
| enableTopologySpreadConstraints | bool | `false` |  |
| envFrom | list | `[]` | Used to set additional environment variables for the pod-mutator container via configMaps or secrets. |
| fullnameOverride | string | `"castai-pod-mutator"` |  |
| global | object | `{"commonAnnotations":{},"commonLabels":{}}` | Values to apply for the parent and child chart resources. |
| global.commonAnnotations | object | `{}` | Annotations to add to all resources. |
| global.commonLabels | object | `{}` | Labels to add to all resources. |
| hostNetwork | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/pod-mutator"` |  |
| image.tag | string | `""` |  |
| mutator.processingDelay | string | `"30s"` |  |
| nameOverride | string | `""` |  |
| podAnnotations | object | `{}` | Annotations added to each pod. |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1005` |  |
| podSecurityContext.runAsGroup | int | `1005` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1005` |  |
| priorityClass.enabled | bool | `true` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| replicas | int | `2` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"20m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| service.webhookPortName | string | `"https"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| topologySpreadConstraints[0].labelSelector.matchLabels."app.kubernetes.io/name" | string | `"castai-pod-mutator"` |  |
| topologySpreadConstraints[0].maxSkew | int | `1` |  |
| topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| webhook.failurePolicy | string | `"Ignore"` |  |
| webhook.reinvocationPolicy | string | `"Never"` |  |
| webhook.url | string | `""` |  |