# castai-agent

CAST AI agent deployment chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv.PPROF_PORT | string | `"6060"` |  |
| additionalSecretEnv | object | `{}` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].key | string | `"provisioner.cast.ai/managed-by"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].operator | string | `"In"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].values[0] | string | `"cast.ai"` |  |
| affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"castai-agent"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| apiKey | string | `""` | Token to be used for authorizing agent access to the API. |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing agent access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| apiURL | string | `"https://api.cast.ai"` | URL to the CAST AI API server. |
| clusterVPA | object | `{"enabled":true,"pollPeriodSeconds":300,"repository":"registry.k8s.io/cpa/cpvpa","resources":{},"version":"v0.8.4"}` | Cluster proportional vertical autoscaler for the agent deployment https://github.com/kubernetes-sigs/cluster-proportional-vertical-autoscaler. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| createNamespace | bool | `true` | Specifies whether a namespace should be created. |
| dnsPolicy | string | `""` |  |
| fullnameOverride | string | `"castai-agent"` |  |
| hostNetwork.enabled | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/agent"` |  |
| nameOverride | string | `""` |  |
| namespace | string | `"castai-agent"` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` | Annotations to be added to agent pods. |
| podLabels | object | `{}` | Labels to be added to agent pods. |
| priorityClass.enabled | bool | `true` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| provider | string | `""` | Name of the Kubernetes service provider one of: "eks", "gks", "aks", "kops". |
| rbac | object | `{"enabled":true}` | Specifies whether RBAC Clusterrole should be created. |
| replicaCount | int | `1` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.fsGroup | int | `1002` |  |
| securityContext.runAsGroup | int | `1002` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1002` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | object | `{}` |  |
| trustedCACert | string | `""` | CA certificate to add to agent's set of root certificate authorities that client will use when verifying server certificates. |
| trustedCACertSecretRef | string | `""` | Name of secret with CA certificate to be added to agent's set of root certificate authorities. trustedCACert and trustedCACertSecretRef are mutually exclusive. The referenced secret must provide the certificate in .data["TLS_CA_CERT_FILE"]. |