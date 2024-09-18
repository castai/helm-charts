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
| config.gcpCredentials | string | `""` |  |
| config.tls.enabled | bool | `true` |  |
| fullnameOverride | string | `""` |  |
| gcpConfiguration.auth | object | `{"jsonCredentials":"","jsonCredentialsSecretRef":"","useMetadataServer":true}` | Select the authentication mode to use to access Google Cloud APIs. Exactly one option from [metadata, raw JSON, secret reference] must be provided. |
| gcpConfiguration.auth.jsonCredentials | string | `""` | JSON credentials to use when authenticating against GCP. |
| gcpConfiguration.auth.jsonCredentialsSecretRef | string | `""` | Secret to mount JSON credentials from. |
| gcpConfiguration.auth.useMetadataServer | bool | `true` | Authenticate via node's metadata server. Requires to be running on a google cloud compute node. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/cloud-proxy"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
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
