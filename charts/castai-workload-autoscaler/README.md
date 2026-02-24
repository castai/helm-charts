# castai-workload-autoscaler

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.87.0](https://img.shields.io/badge/AppVersion-v0.87.0-informational?style=flat-square)

CAST AI workload autoscaler.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set any additional environment variables. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].values[0] | string | `"castai-workload-autoscaler"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| autopilot.autoDetect | bool | `true` |  |
| autopilot.enabled | bool | `false` |  |
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiURL | string | `"https://api.cast.ai"` |  |
| castai.apiUrl | string | `nil` | Deprecated, use `castai.apiURL` instead (using this value will override `castai.apiURL`). |
| castai.clusterID | string | `""` |  |
| castai.clusterIdSecretKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai.clusterIdSecretKeyRef.name | string | `""` |  |
| castai.configMapRef | string | `""` |  |
| castai.telemetryURL | string | `"auto"` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using custom CNI's. Defaults to "ClusterFirstWithHostNet" if hostNetwork is true |
| envFrom | list | `[]` | Used to set additional environment variables for the workload autoscaler container via configMaps or secrets. |
| evictionRateLimitingEnabled | bool | `true` | Enable rate limiting pod evictions by workload autoscaler. |
| extraVolumeMounts | list | `[]` | Used to set additional volumemounts |
| extraVolumes | list | `[]` | Used to set additional volumes |
| fullnameOverride | string | `"castai-workload-autoscaler"` |  |
| healthProbe.port | int | `8081` |  |
| hostNetwork | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/workload-autoscaler"` |  |
| image.tag | string | `""` |  |
| inPlaceResizeDeferredEnabled | bool | `true` | Enables applying deferred recommendations using the In-Place Resize feature. Requires 'inPlaceResizeEnabled' to be set to true. |
| inPlaceResizeEnabled | bool | `true` | Enables the Kubernetes Pod In-Place Resize feature, allowing workloads to scale resources without recreating pods. It requires k8s >= 1.33 |
| leaderElection.leaseName | string | `"castai-workload-autoscaler"` |  |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.httpGet.path | string | `"/readyz"` |  |
| livenessProbe.httpGet.port | int | `8081` |  |
| livenessProbe.initialDelaySeconds | int | `10` |  |
| livenessProbe.periodSeconds | int | `15` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `15` |  |
| metrics.port | int | `8080` |  |
| metrics.targetPort | int | `8080` |  |
| openshift.scc.enabled | bool | `true` | Whether to create SecurityContextConstraints on OpenShift. Set to false to disable SCC creation and rely on OpenShift's default restricted-v2 SCC. |
| openshift.scc.priority | int | `5` | Priority for the SecurityContextConstraints resource. Lower priority than OpenShift's anyuid (10) to avoid conflicts during cluster upgrades. Set to null for lowest priority, or customize based on your environment. WARNING: Using priority 10 or higher can cause authentication issues during upgrades. See https://access.redhat.com/solutions/4727461 for details. |
| openshift.scc.useRestrictedProfile | bool | `false` | When true, uses OpenShift-compatible settings: - runAsUser uses MustRunAsRange instead of MustRunAs (allows OpenShift to assign UID) - fsGroup and supplementalGroups use RunAsAny - readOnlyRootFilesystem removed from SCC (still enforced in pod spec) This prevents the SCC from being selected for unrelated workloads. |
| podAnnotations | object | `{}` | Annotations added to each pod. |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1005` |  |
| podSecurityContext.runAsGroup | int | `1005` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1005` |  |
| priorityClass.enabled | bool | `true` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| readinessProbe.failureThreshold | int | `6` |  |
| readinessProbe.httpGet.path | string | `"/healthz"` |  |
| readinessProbe.httpGet.port | int | `8081` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `15` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `15` |  |
| replicas | int | `2` |  |
| resourceQuotaAwareScaling | object | `{"enabled":false,"headroomPercent":10}` | Configuration for resource quota aware scaling. When enabled, prevents upscaling workloads when doing so would violate namespace ResourceQuotas. |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| telemetryDebug | object | `{"enabled":false,"interval":"1m"}` | Configuration for telemetry debug to collect controller runtime metrics. When enabled, the controller emits its own Prometheus metrics (memory, CPU, cache size, etc.) to CAST AI. |
| test.enabled | bool | `true` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| tolerations[1].key | string | `"provisioning.cast.ai/temporary"` |  |
| tolerations[1].operator | string | `"Exists"` |  |
| tolerations[2].key | string | `"CriticalAddonsOnly"` |  |
| tolerations[2].operator | string | `"Exists"` |  |
| trustedCACert | string | `""` | CA certificate to add to set of root certificate authorities that client will use when verifying server certificates. |
| trustedCACertSecretRef | string | `""` | Name of secret with CA certificate to be added to agent's set of root certificate authorities. trustedCACert and trustedCACertSecretRef are mutually exclusive. The referenced secret must provide the certificate in .data["TLS_CA_CERT_FILE"]. |
| watchListClient | bool | `true` |  |
| webhook.failurePolicy | string | `"Ignore"` |  |
| webhook.port | int | `9443` |  |
| webhook.reinvocationPolicy | string | `"IfNeeded"` |  |
| webhook.url | string | `""` |  |
| workloadPodLabeling | object | `{"workloadId":{"enabled":false}}` | Configuration for Workload Autoscaler features that dynamically add labels to user workload pods during rightsizing. This is distinct from 'podLabels' and 'podAnnotations', which apply only to the workload-autoscaler pods themselves. |
| workloadWhitelistingEnabled | bool | `false` | Enable whitelisting mode for workload autoscaler. When set to true, only workloads explicitly labeled as whitelisted will be scaled. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
