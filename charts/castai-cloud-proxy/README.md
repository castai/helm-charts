# castai-cloud-proxy

CAST AI cloud-proxy chart

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{"LOG_LEVEL":"4"}` | Used to set additional environment variables for the cloud-proxy container. |
| affinity | object | `{}` |  |
| castai | object | `{"apiKey":"","apiKeySecretRef":"","apiURL":"https://api.cast.ai","clusterID":"","grpcURL":"api-grpc.cast.ai:443"}` | CAST AI specific settings |
| castai.apiKey | string | `""` | The CAST AI API key. Either this or apiKeySecretRef must be provided. |
| castai.apiKeySecretRef | string | `""` | Kubernetes Secret reference for the CAST AI API key. Either this or apiKey must be provided. |
| castai.apiURL | string | `"https://api.cast.ai"` | The CAST AI API URL. |
| castai.clusterID | string | `""` | The CAST AI cluster ID. |
| castai.grpcURL | string | `"api-grpc.cast.ai:443"` | The CAST AI gRPC URL. |
| commonAnnotations | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| gcpConfiguration.auth | object | `{"jsonCredentials":"","jsonCredentialsSecretRef":""}` | Select the authentication mode to use to access Google Cloud APIs. If you do not specify any, the metadata server will be used. |
| gcpConfiguration.auth.jsonCredentials | string | `""` | JSON credentials to use when authenticating against GCP. |
| gcpConfiguration.auth.jsonCredentialsSecretRef | string | `""` | Secret to mount JSON credentials from. The credentials JSON must be provided in the `google-credentials.json` key. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/cloud-proxy"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/livez"` |  |
| livenessProbe.httpGet.port | int | `9091` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `1` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| priorityClass.enabled | bool | `true` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | int | `9091` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `1` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
