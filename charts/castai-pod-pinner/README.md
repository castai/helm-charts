# castai-pod-pinner

CAST AI Pod Pinning deployment chart.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/castai-pod-pinner-ext | castai-pod-pinner-ext | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` | Used to set additional environment variables for the pod-pinner container. |
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"provisioner.cast.ai/managed-by","operator":"In","values":["cast.ai"]}]},"weight":100}],"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"NotIn","values":["windows"]}]}]}}}` | Affinity for the pod-pinner pod. |
| castai | object | `{"apiKey":"","apiKeySecretRef":"","apiURL":"https://api.cast.ai","clusterID":"","grpcURL":"grpc.cast.ai:443"}` | CAST AI settings for the pod-pinner. |
| castai.apiKey | string | `""` | The CAST AI API key. Either this or apiKeySecretRef must be provided. |
| castai.apiKeySecretRef | string | `""` | Kubernetes Secret reference for the CAST AI API key. Either this or apiKey must be provided. |
| castai.apiURL | string | `"https://api.cast.ai"` | The CAST AI API URL. |
| castai.clusterID | string | `""` | The CAST AI cluster ID. |
| castai.grpcURL | string | `"grpc.cast.ai:443"` | The CAST AI gRPC URL. |
| global | object | `{"commonAnnotations":{},"commonLabels":{},"fullnameOverride":"","nameOverride":"","serviceAccount":{"annotations":{},"create":true,"name":""}}` | Values to apply for the parent and child chart resources. |
| global.nameOverride | string | `""` | Override the name of the chart. |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"us-docker.pkg.dev/castai-hub/library/pod-pinner","tag":""}` | Image settings for the pod-pinner container. |
| image.pullPolicy | string | `"IfNotPresent"` | The image pull policy. |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/pod-pinner"` | The image repository to use. |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets to use for the pod-pinner pod. |
| nodeSelector | object | `{}` | Node selector for the pod-pinner pod. |
| podAnnotations | object | `{}` | Extra annotations to add to the pod. |
| podLabels | object | `{}` | Extra labels to add to the pod. |
| podSecurityContext | object | `{}` | Pod security context. |
| replicaCount | int | `2` | Replica count for the pod-pinner deployment. |
| resources | object | `{"limits":{"memory":"100Mi"},"requests":{"cpu":"20m","memory":"100Mi"}}` | Pod-pinner container resources. |
| securityContext | object | `{"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` | Security context for the pod-pinner container. |
| service | object | `{"port":8443,"type":"ClusterIP"}` | Service settings for the pod-pinner. |
| service.port | int | `8443` | The service port to use. The port is restricted to certain values because the webhook server uses this port. |
| service.type | string | `"ClusterIP"` | The service type to use. |
| tolerations | list | `[]` | Tolerations for the pod-pinner pod. |
| webhook | object | `{"failurePolicy":"Ignore","url":""}` | Webhook settings for the pod-pinner. |
| webhook.failurePolicy | string | `"Ignore"` | Overrides the failure policy of the webhook whose default is Ignore. |
| webhook.url | string | `""` | Overrides webhook service routing and uses the provided url instead. |