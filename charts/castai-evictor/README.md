# castai-evictor

Cluster utilization defragmentation tool

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/castai-evictor-ext | castai-evictor-ext | 0.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set any additional environment variables. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| aggressiveMode | bool | `false` | Specifies whether the Evictor can behave as aggressive if true, evictor will start considering single replica pods as long as they can be scheduled somewhere else. |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing evictor access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` | key of the cluster id value in the config map |
| clusterIdConfigMapKeyRef.name | string | `""` | name and of the config map with cluster id |
| clusterIdSecretKeyRef.key | string | `"CLUSTER_ID"` |  |
| clusterIdSecretKeyRef.name | string | `""` |  |
| clusterVPA | object | `{"enabled":true,"pollPeriodSeconds":300,"repository":"registry.k8s.io/cpa/cpvpa","resources":{},"version":"v0.8.4"}` | Cluster proportional vertical autoscaler for the evictor deployment https://github.com/kubernetes-sigs/cluster-proportional-vertical-autoscaler. |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{}` | Labels to add to all resources. |
| configMapLabels | object | `{}` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| customConfig | object | `{}` |  |
| cycleInterval | string | `"1m"` | Specifies the interval between eviction cycles. This property can be used to lower or raise the frequency of the evictor's find-and-drain operations. |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using some custom CNI's. |
| dryRun | bool | `false` |  |
| envFrom | list | `[]` | Additional environment sources for the evictor container. Accepts a list of `configMapRef` or `secretRef` entries, following the standard `envFrom` format. |
| extraVolumeMounts | list | `[]` | Used to set additional volume mounts. |
| extraVolumes | list | `[]` | Used to set additional volumes. |
| fullnameOverride | string | `"castai-evictor"` |  |
| hostNetwork.enabled | bool | `false` | Enable host networking. |
| ignorePodDisruptionBudgets | bool | `false` | Specifies whether the Evictor should ignore Pod Disruption Budgets (PDBs). If true, evictor will attempt to evict pods even if it would violate a PDB. Use with caution as this may disrupt application availability guarantees. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/evictor"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| karpenterMode | object | `{"enabled":false}` | Specifies settings for working with Karpenter NodePool and NodeClaim resources. |
| karpenterNodeCleanup | object | `{"enabled":false}` | Specifies Karpenter node cleanup parameters. |
| karpenterNodeCleanup.enabled | bool | `false` | Whether to enable cleanup of Karpenter nodes. |
| kubernetesClient | object | `{"rateLimiter":{"burst":200,"qps":100}}` | Specifies Kubernetes client settings. |
| kubernetesClient.rateLimiter.burst | int | `200` | Burst controls the maximum queries per second that the client is allowed to issue in a short burst. |
| kubernetesClient.rateLimiter.qps | int | `100` | QPS or queries per second. Controls how many queries per second the client should be allowed to issue, not accounting for bursts. |
| leaderElection | object | `{"enabled":true}` | Specifies leader election parameters. |
| leaderElection.enabled | bool | `true` | Whether to enable leader election. |
| liveMigration | object | `{"enabled":true,"useK8sClientCache":true}` | Specifies LIVE migration settings. This options assumes that the CAST AI LIVE components are already installed in the cluster. |
| managedByCASTAI | bool | `true` | Specifies whether the Evictor was installed using mothership and is automatically updated by CAST AI. Alternative scenarios are, when CAST AI is not managing charts, and customers' are install them with Argo CD/Terraform or something else. |
| maxNodesToEvictPerCycle | int | `20` | Specifies the max nodes evictor can evict in a single cycle. |
| nameOverride | string | `""` |  |
| nodeGracePeriodMinutes | int | `5` | Specifies the grace period after a node is created before it is considered for eviction The number of minutes a node must exist before it will be considered. |
| nodeSelector | object | `{}` |  |
| openshift.scc.enabled | bool | `true` |  |
| openshift.scc.priority | int | `5` |  |
| openshift.scc.useRestrictedProfile | bool | `false` |  |
| overrideEnvFrom | bool | `false` | If set to true, completely overrides the default `envFrom` section for the evictor container. When false (default), values provided here will be appended to the chart's defaults. |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| rbac.enabled | bool | `true` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| scopedMode | bool | `false` |  |
| securityContext.fsGroup | int | `1004` |  |
| securityContext.runAsGroup | int | `1004` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1004` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` |  |
| updateStrategy | object | `{"type":"Recreate"}` | Controls `deployment.spec.strategy` field. |
| woop | object | `{"enabled":true,"useK8sClientCache":true}` | Specifies settings for working with WOOP recommendations. |