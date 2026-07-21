# castai-evictor

Cluster utilization defragmentation tool

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/castai-evictor-ext | castai-evictor-ext | 0.5.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set any additional environment variables. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| aggressiveMode | bool | `false` | Specifies whether the Evictor can behave as aggressive if true, evictor will start considering single replica pods as long as they can be scheduled somewhere else. |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing evictor access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| arm64Supported | bool | `true` | Indicates arm64 nodes are present so the scheduling simulation includes them as valid targets. (CR field, not yet read by evictor) |
| clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` | key of the cluster id value in the config map |
| clusterIdConfigMapKeyRef.name | string | `""` | name and of the config map with cluster id |
| clusterIdSecretKeyRef.key | string | `"CLUSTER_ID"` |  |
| clusterIdSecretKeyRef.name | string | `""` |  |
| clusterVPA | object | `{"enabled":true,"pollPeriodSeconds":300,"repository":"us-docker.pkg.dev/castai-hub/library/cpa/cpvpa","resources":{},"version":"v0.8.12"}` | Cluster proportional vertical autoscaler for the evictor deployment https://github.com/kubernetes-sigs/cluster-proportional-vertical-autoscaler. |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{}` | Labels to add to all resources. |
| configMapLabels | object | `{}` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| crdUpgrade | object | `{"enabled":true,"image":{"digest":"","pullPolicy":"IfNotPresent","repository":"rancher/kubectl","tag":"v1.35.6"},"imagePullSecrets":[],"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}}` | CRD upgrade configuration. Enables automatic CRD upgrade during helm install/upgrade operations via a pre-install/pre-upgrade hook Job. |
| crdUpgrade.image.digest | string | `""` | Image digest for pinning (e.g. sha256:abc...). When set, appended to the image reference. |
| crdUpgrade.imagePullSecrets | list | `[]` | Image pull secrets for the CRD upgrade Job. Use when crdUpgrade.image.repository points to a private registry that requires authentication. Independent of the evictor imagePullSecrets. |
| crdUpgrade.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | Resource requests/limits for the CRD upgrade Job container. |
| customConfig | object | `{}` |  |
| cycleInterval | string | `"1m"` | Specifies the interval between eviction cycles. This property can be used to lower or raise the frequency of the evictor's find-and-drain operations. |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using some custom CNI's. |
| drainRollbackTimeout | string | `"1m"` | How long the evictor waits before rolling back a cordon when a drain attempt fails. (CR field, not yet read by evictor) |
| drainTimeout | string | `"10m"` | Maximum time the evictor waits for a node to fully drain before giving up. (CR field, not yet read by evictor) |
| dryRun | bool | `false` |  |
| emitNodeRelatedPodEvents | bool | `false` | Emit Kubernetes events on pods when they are evicted as part of a node drain. (CR field, not yet read by evictor) |
| envFrom | list | `[]` | Additional environment sources for the evictor container. Accepts a list of `configMapRef` or `secretRef` entries, following the standard `envFrom` format. |
| evictorEnabled | bool | `true` | Top-level kill-switch for the evictor. (CR field, not yet read by evictor) When false, no evictions or node drains are performed regardless of other settings. |
| extraVolumeMounts | list | `[]` | Used to set additional volume mounts. |
| extraVolumes | list | `[]` | Used to set additional volumes. |
| forceDisableKarpenterMode | bool | `true` | Disables Karpenter-aware scheduling simulation (CR field, not yet read by evictor) even when Karpenter is detected on the cluster. Capability-detected by the evictor. |
| fullnameOverride | string | `"castai-evictor"` |  |
| global | object | `{"castai":{"apiKeySecretRef":""},"imagePullSecrets":[],"rbac":{"clusterScoped":{"enabled":true}},"registry":""}` | Global values propagated from parent charts. |
| global.castai.apiKeySecretRef | string | `""` | Name of a pre-existing Secret containing the CAST AI API key. Takes effect when apiKeySecretRef is not set locally. |
| global.imagePullSecrets | list | `[]` | Image pull secrets applied to all pods. Merged with local imagePullSecrets. |
| global.rbac.clusterScoped.enabled | bool | `true` | Enable cluster-scoped RBAC resources (ClusterRole, ClusterRoleBinding). Set to false to disable cluster-scoped RBAC if using namespace-scoped permissions. |
| global.registry | string | `""` | Container registry prefix for all images (e.g. "my-registry.example.com"). When set, it is prepended to all image repositories. |
| hostNetwork.enabled | bool | `false` | Enable host networking. |
| ignorePodDisruptionBudgets | bool | `false` | Specifies whether the Evictor should ignore Pod Disruption Budgets (PDBs). If true, evictor will attempt to evict pods even if it would violate a PDB. Use with caution as this may disrupt application availability guarantees. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/evictor"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| karpenterNodeCleanup | object | `{"enabled":false}` | Karpenter NodeClaim cleanup for nodes Evictor has drained. When enabled, Evictor deletes the Karpenter NodeClaim for any node it has successfully drained, so Karpenter's termination controller can clean up the EC2 instance. Requires `nodeclaims.karpenter.sh` get/list/watch/delete permission (granted by this chart). |
| karpenterNodeCleanup.enabled | bool | `false` | Whether to enable cleanup of Karpenter nodes. |
| kubernetesClient | object | `{"rateLimiter":{"burst":200,"qps":100}}` | Specifies Kubernetes client settings. |
| kubernetesClient.rateLimiter.burst | int | `200` | Burst controls the maximum queries per second that the client is allowed to issue in a short burst. |
| kubernetesClient.rateLimiter.qps | int | `100` | QPS or queries per second. Controls how many queries per second the client should be allowed to issue, not accounting for bursts. |
| leaderElection | object | `{"enabled":true}` | Specifies leader election parameters. |
| leaderElection.enabled | bool | `true` | Whether to enable leader election. |
| liveMigration | object | `{"enabled":true,"useK8sClientCache":true}` | Specifies LIVE migration settings. This options assumes that the CAST AI LIVE components are already installed in the cluster. |
| managedByCASTAI | bool | `true` | Specifies whether the Evictor was installed using mothership and is automatically updated by CAST AI. Alternative scenarios are, when CAST AI is not managing charts, and customers' are install them with Argo CD/Terraform or something else. |
| maxNodesToEvictPerCycle | int | `20` | Specifies the max nodes evictor can evict in a single cycle. |
| minNodesToEvictPerCycle | int | `5` | Minimum number of nodes to consider per eviction cycle. (CR field, not yet read by evictor) |
| nameOverride | string | `""` |  |
| nodeGracePeriodMinutes | int | `5` | Specifies the grace period after a node is created before it is considered for eviction The number of minutes a node must exist before it will be considered. |
| nodeSelector | object | `{}` |  |
| openshift.scc.enabled | bool | `true` |  |
| openshift.scc.priority | int | `5` |  |
| openshift.scc.useRestrictedProfile | bool | `false` |  |
| overrideEnvFrom | bool | `false` | If set to true, completely overrides the default `envFrom` section for the evictor container. When false (default), values provided here will be appended to the chart's defaults. |
| podAnnotations | object | `{}` |  |
| podEvictionFailureBackOff | string | `"5s"` | Wait time before retrying after a pod eviction request fails. (CR field, not yet read by evictor) |
| podLabels | object | `{}` |  |
| podMutations | object | `{"enabled":true}` | Specifies settings for working with PodMutation CRs. |
| pricingModel | object | `{"baseCPUCost":"7.0","baseMemCost":"1.0","enabled":false,"spotDiscount":"0.5"}` | Cost coefficients used when pricingAwareness is enabled. (CR field, not yet read by evictor) |
| pricingModel.baseCPUCost | string | `"7.0"` | Cost coefficient per CPU core. |
| pricingModel.baseMemCost | string | `"1.0"` | Cost coefficient per GiB of memory. |
| pricingModel.enabled | bool | `false` | Enable pricing-aware drain candidate selection (prefer draining more expensive nodes first). |
| pricingModel.spotDiscount | string | `"0.5"` | Fractional discount applied to spot instance price relative to on-demand. |
| rbac.enabled | bool | `true` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| scopedMode | bool | `false` |  |
| securityContext.fsGroup | int | `1004` |  |
| securityContext.runAsGroup | int | `1004` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1004` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| softTainting | object | `{"enabled":false}` | Specifies soft tainting parameters. |
| softTainting.enabled | bool | `false` | Whether to enable soft tainting of evicted nodes. |
| targetNodePercentage | int | `10` | Percentage of eligible nodes to consider per cycle, (CR field, not yet read by evictor) applied after min/max target node bounds. |
| tolerations | list | `[]` |  |
| updateStrategy | object | `{"type":"Recreate"}` | Controls `deployment.spec.strategy` field. |
| windows | bool | `false` | Enable eviction of pods and nodes running Windows workloads. (CR field, not yet read by evictor) |
| woop | object | `{"enabled":true,"useK8sClientCache":true}` | Specifies settings for working with WOOP recommendations. |