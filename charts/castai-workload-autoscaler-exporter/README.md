# castai-workload-autoscaler-exporter

![Version: 0.0.99](https://img.shields.io/badge/Version-0.0.99-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.87.0](https://img.shields.io/badge/AppVersion-v0.87.0-informational?style=flat-square)

CAST AI workload autoscaler exporter.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiURL | string | `"https://api.cast.ai"` |  |
| castai.apiUrl | string | `nil` | Deprecated, use `castai.apiURL` instead (using this value will override `castai.apiURL`). |
| castai.clusterID | string | `""` |  |
| castai.clusterIdSecretKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai.clusterIdSecretKeyRef.name | string | `""` |  |
| castai.configMapRef | string | `""` |  |
| castai.telemetryURL | string | `"auto"` |  |
| clusterDomain | string | `"cluster.local"` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| envFrom | list | `[]` | Used to set additional environment variables for the exporter container via configMaps or secrets. |
| exporter.config.concurrency | int | `10` |  |
| exporter.config.failureLimit | int | `5` |  |
| exporter.config.failure_limit | string | `nil` |  |
| exporter.config.interval | string | `"15s"` |  |
| exporter.config.metricLimit | int | `5000` |  |
| exporter.config.metric_limit | string | `nil` |  |
| exporter.config.metricsClientInsecure | bool | `false` |  |
| exporter.config.nodeWorkloads[0].datasource.kubeletPort | int | `10250` |  |
| exporter.config.nodeWorkloads[0].datasource.metricsPath | string | `"/metrics/probes"` |  |
| exporter.config.nodeWorkloads[0].datasource.name | string | `"node-probes"` |  |
| exporter.config.nodeWorkloads[0].metrics[0].name | string | `"prober_probe_total"` |  |
| exporter.config.nodeWorkloads[0].transformer | string | `"node-probes"` |  |
| exporter.config.nodeWorkloads[1].datasource.kubeletPort | int | `10250` |  |
| exporter.config.nodeWorkloads[1].datasource.metricsPath | string | `"/metrics/cadvisor"` |  |
| exporter.config.nodeWorkloads[1].datasource.name | string | `"node-psi"` |  |
| exporter.config.nodeWorkloads[1].kubernetesVersion | string | `">= 1.34.0-0"` |  |
| exporter.config.nodeWorkloads[1].metrics[0].filterExpr | string | `"container != \"\""` |  |
| exporter.config.nodeWorkloads[1].metrics[0].name | string | `"container_pressure_cpu_waiting_seconds_total"` |  |
| exporter.config.nodeWorkloads[1].metrics[1].filterExpr | string | `"container != \"\""` |  |
| exporter.config.nodeWorkloads[1].metrics[1].name | string | `"container_pressure_memory_waiting_seconds_total"` |  |
| exporter.config.nodeWorkloads[1].transformer | string | `"node-psi"` |  |
| exporter.config.prometheus | list | `[]` |  |
| exporter.healthProbe.port | int | `8081` |  |
| exporter.image.pullPolicy | string | `"IfNotPresent"` |  |
| exporter.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/workload-autoscaler"` |  |
| exporter.image.tag | string | `""` |  |
| exporter.livenessProbe.failureThreshold | int | `6` |  |
| exporter.livenessProbe.httpGet.path | string | `"/readyz"` |  |
| exporter.livenessProbe.httpGet.port | int | `8081` |  |
| exporter.livenessProbe.initialDelaySeconds | int | `10` |  |
| exporter.livenessProbe.periodSeconds | int | `15` |  |
| exporter.livenessProbe.successThreshold | int | `1` |  |
| exporter.livenessProbe.timeoutSeconds | int | `15` |  |
| exporter.metrics.port | int | `8080` |  |
| exporter.readinessProbe.failureThreshold | int | `6` |  |
| exporter.readinessProbe.httpGet.path | string | `"/healthz"` |  |
| exporter.readinessProbe.httpGet.port | int | `8081` |  |
| exporter.readinessProbe.initialDelaySeconds | int | `10` |  |
| exporter.readinessProbe.periodSeconds | int | `15` |  |
| exporter.readinessProbe.successThreshold | int | `1` |  |
| exporter.readinessProbe.timeoutSeconds | int | `15` |  |
| exporter.resources.limits.cpu | int | `2` |  |
| exporter.resources.limits.memory | string | `"512Mi"` |  |
| exporter.resources.requests.cpu | string | `"500m"` |  |
| exporter.resources.requests.memory | string | `"256Mi"` |  |
| exporter.serviceAccount.create | bool | `true` |  |
| exporter.serviceAccount.name | string | `""` |  |
| fullnameOverride | string | `"castai-workload-autoscaler-exporter"` |  |
| openshift.scc.enabled | bool | `true` | Whether to create SecurityContextConstraints on OpenShift. Set to false to disable SCC creation and rely on OpenShift's default restricted-v2 SCC. |
| openshift.scc.priority | int | `5` | Priority for the SecurityContextConstraints resource. Lower priority than OpenShift's anyuid (10) to avoid conflicts during cluster upgrades. Set to null for lowest priority, or customize based on your environment. WARNING: Using priority 10 or higher can cause authentication issues during upgrades. See https://access.redhat.com/solutions/4727461 for details. |
| openshift.scc.useRestrictedProfile | bool | `false` | When true, uses OpenShift-compatible settings: - runAsUser uses MustRunAsRange instead of MustRunAs (allows OpenShift to assign UID) - fsGroup and supplementalGroups use RunAsAny - readOnlyRootFilesystem removed from SCC (still enforced in pod spec) This prevents the SCC from being selected for unrelated workloads. |
| podSecurityContext.fsGroup | int | `1006` |  |
| podSecurityContext.runAsGroup | int | `1006` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1006` |  |
| prometheus.enabled | bool | `false` |  |
| prometheus.image.pullPolicy | string | `"IfNotPresent"` |  |
| prometheus.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/prom/prometheus"` |  |
| prometheus.image.tag | string | `"v3.2.1"` |  |
| prometheus.replicaCount | int | `1` |  |
| prometheus.resources.limits.cpu | string | `"500m"` |  |
| prometheus.resources.limits.memory | string | `"1Gi"` |  |
| prometheus.resources.requests.cpu | string | `"250m"` |  |
| prometheus.resources.requests.memory | string | `"512Mi"` |  |
| prometheus.scrape | list | `[]` |  |
| prometheus.scrapeConfigs | list | `[]` |  |
| prometheus.service.port | int | `9090` |  |
| prometheus.service.type | string | `"ClusterIP"` |  |
| prometheus.storage.retention | string | `"1h"` |  |
| prometheus.storage.size | string | `"2Gi"` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| workloadWhitelistingEnabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
