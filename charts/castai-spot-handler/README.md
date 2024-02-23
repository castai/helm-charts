# castai-spot-handler

Spot Handler is the component responsible for scheduled events monitoring and delivering them to the central platform.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv.LOG_LEVEL | string | `"5"` |  |
| additionalEnv.POLL_INTERVAL_SECONDS | string | `"3"` |  |
| affinity | object | `{}` |  |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing access to the API The referenced secret must provide the token in .data["API_KEY"] |
| castai.apiURL | string | `"https://api.cast.ai"` | CASTAI public api url. |
| castai.clusterID | string | `""` | CASTAI Cluster unique identifier. |
| castai.provider | string | `""` | Cloud provider (azure, gcp, aws). |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/spot-handler"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | object | `{}` | what secret should be used for pulling the image |
| nodeSelector."scheduling.cast.ai/spot" | string | `"true"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| rbac.enabled | bool | `true` |  |
| resources.limits.memory | string | `"25Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"25Mi"` |  |
| securityContext.fsGroup | int | `1003` |  |
| securityContext.runAsGroup | int | `1003` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1003` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.name | string | `"castai-spot-handler"` |  |
| tolerations[0].effect | string | `"NoSchedule"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| updateStrategy | object | `{}` | Controls `daemonset.spec.updateStrategy` field. |
| useHostNetwork | bool | `true` | Host network is used to access instance metadata endpoints which are not always available from pod network. |