# castai-pod-pinner

CAST AI Pod Pinning deployment chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` |  |
| affinity | object | `{}` |  |
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiURL | string | `"https://api.cast.ai"` |  |
| castai.clusterID | string | `""` |  |
| castai.grpcURL | string | `"grpc.cast.ai:443"` |  |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| deploy | bool | `true` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/pod-pinner"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| namespace | string | `"castai-agent"` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"100Mi"` |  |
| resources.requests.cpu | string | `"20m"` |  |
| resources.requests.memory | string | `"100Mi"` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.port | int | `443` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| webhook.failurePolicy | string | `"Ignore"` |  |
| webhook.port | int | `10250` |  |
| webhook.url | string | `""` |  |