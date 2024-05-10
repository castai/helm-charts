# castai-evictor

Cluster utilization defragmentation tool

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/castai-evictor-ext | castai-evictor-ext | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set any additional environment variables. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| aggressiveMode | bool | `false` | Specifies whether the Evictor can behave as aggressive if true, evictor will start considering single replica pods as long as they can be scheduled somewhere else. |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing evictor access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
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
| fullnameOverride | string | `"castai-evictor"` |  |
| hostNetwork.enabled | bool | `false` | Enable host networking. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/evictor"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| leaderElection | object | `{"enabled":true}` | Specifies leader election parameters. |
| leaderElection.enabled | bool | `true` | Whether to enable leader election. |
| managedByCASTAI | bool | `false` | Specifies whether the Evictor was installed using mothership and is automatically updated by CAST AI. Alternative scenarios are, when CAST AI is not managing charts, and customers' are install them with Argo CD/Terraform or something else. |
| maxNodesToEvictPerCycle | int | `20` | Specifies the max nodes evictor can evict in a single cycle. |
| nameOverride | string | `""` |  |
| nodeGracePeriodMinutes | int | `5` | Specifies the grace period after a node is created before it is considered for eviction The number of minutes a node must exist before it will be considered. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
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