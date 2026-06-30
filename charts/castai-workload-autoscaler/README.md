# castai-workload-autoscaler

![Version: 1.3.2](https://img.shields.io/badge/Version-1.3.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.3.2](https://img.shields.io/badge/AppVersion-v1.3.2-informational?style=flat-square)

CAST AI workload autoscaler.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set any additional environment variables. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
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
| clusterAutoscaler | object | `{"args":{"scale-down-delay-after-add":"0s","scale-down-delay-after-delete":"0s","scale-down-delay-after-failure":"30s","scale-down-unneeded-time":"30s","scale-down-unready-time":"1m","scan-interval":"10s"},"enabled":true}` | Configuration for injecting optimized CLI args into cluster-autoscaler pods. The mutating webhook detects CA pods on CREATE and appends configured args. Existing flags set by the customer are never overridden. |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using custom CNI's. Defaults to "ClusterFirstWithHostNet" if hostNetwork is true |
| envFrom | list | `[]` | Used to set additional environment variables for the workload autoscaler container via configMaps or secrets. |
| evictionRateLimitingEnabled | bool | `true` | Enable rate limiting pod evictions by workload autoscaler. |
| extraVolumeMounts | list | `[]` | Used to set additional volumemounts |
| extraVolumes | list | `[]` | Used to set additional volumes |
| forceFinalizeAfter | string | `"15m"` |  |
| fullnameOverride | string | `"castai-workload-autoscaler"` |  |
| global.castai.apiKeySecretRef | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.registry | string | `""` |  |
| gpu.enabled | bool | `false` |  |
| healthProbe.port | int | `8081` |  |
| hostNetwork | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/workload-autoscaler"` |  |
| image.tag | string | `""` |  |
| inPlaceResizeDeferredEnabled | bool | `true` | Enables applying deferred recommendations using the In-Place Resize feature. Requires 'inPlaceResizeEnabled' to be set to true. |
| inPlaceResizeEnabled | bool | `true` | Enables the Kubernetes Pod In-Place Resize feature, allowing workloads to scale resources without recreating pods. It requires k8s >= 1.33 |
| jmxExporter | object | `{"basePort":9404,"enabled":true,"imagePullSecrets":[],"initImage":{"repository":"us-docker.pkg.dev/castai-hub/library/jmx-exporter-init","tag":"1.5.0-v1"},"resources":{}}` | Configuration for auto-instrumenting JVM pods with the JMX Prometheus Java agent. When enabled, the mutating webhook injects an init container that copies the agent jar into a shared emptyDir volume, sets JDK_JAVA_OPTIONS on every app container, and exposes ports starting from the configured basePort (default: 9404, 9405, ...).  The injected init container runs as UID 65532 (non-root) with a SecurityContext matching the Pod Security Standard "restricted" profile. Pods that also enforce runAsNonRoot at the pod level must additionally set `pod.spec.securityContext.fsGroup` so the init container can write to the shared emptyDir volume. Without fsGroup, the agent files cannot be staged and JVM auto-instrumentation will not work for that pod. |
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
| preDeleteHook | object | `{"activeDeadlineSeconds":300,"backoffLimit":3,"enabled":true,"optionalConfig":true}` | Configuration for the Helm pre-delete hook that strips finalizers from all Recommendation CRs before the agent is uninstalled.  How it works:   1. When `helm uninstall` is run, Helm executes this Job first.   2. The Job strips finalizers from all Recommendation CRs cluster-wide.   3. Helm then deletes the CRD, which cascades to all CR instances.   4. Workload resource mutations are NOT reverted — pods keep their current resources.  Note: this only applies to clean `helm uninstall`. Forceful removal of the agent (e.g. deleting the Deployment directly) bypasses this hook entirely. |
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
| resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"512Mi"}}` | requests/limits applied to the injected castai-jmx-exporter-init container. Required in clusters with ResourceQuotas that mandate CPU/memory on every container. Any field left empty is omitted on the container (e.g., set requests only, no limits). |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.rbac | bool | `true` |  |
| telemetryDebug | object | `{"enabled":false,"interval":"1m"}` | Configuration for telemetry debug to collect controller runtime metrics. When enabled, the controller emits its own Prometheus metrics (memory, CPU, cache size, etc.) to CAST AI. |
| test.enabled | bool | `true` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| tolerations[1].key | string | `"CriticalAddonsOnly"` |  |
| tolerations[1].operator | string | `"Exists"` |  |
| topologySpreadConstraints[0].labelSelector.matchLabels."app.kubernetes.io/name" | string | `"castai-workload-autoscaler"` |  |
| topologySpreadConstraints[0].maxSkew | int | `1` |  |
| topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
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
