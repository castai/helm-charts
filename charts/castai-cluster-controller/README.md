# castai-cluster-controller

Cluster controller is responsible for handling certain Kubernetes actions such as draining and deleting nodes, adding labels, approving CSR requests.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/castai-cluster-controller-ext | castai-cluster-controller-ext | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{"LOG_LEVEL":"5","MONITOR_METADATA":"/controller-metadata/metadata"}` | Env variables passed to castai-cluster-controller. |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/os"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"NotIn"` |  |
| affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"windows"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].values[0] | string | `"castai-cluster-controller"` |  |
| affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| autoscaling | object | `{"enabled":true}` | Settings for managing autoscaling features. |
| autoscaling.enabled | bool | `true` | Adds permissions to manage autoscaling. |
| castai | object | `{"apiKey":"","apiKeySecretRef":"","apiURL":"https://api.cast.ai","clusterID":"","clusterIdSecretKeyRef":{"key":"CLUSTER_ID","name":""}}` | CAST AI API configuration. |
| castai.apiKey | string | `""` | Token to be used for authorizing agent access to the CASTAI API. |
| castai.apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing agent access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| castai.apiURL | string | `"https://api.cast.ai"` | CASTAI public api url. |
| castai.clusterID | string | `""` | CASTAI Cluster unique identifier. clusterID and clusterIdSecretKeyRef are mutually exclusive |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| createNamespace | bool | `false` | By default namespace is expected to be created by castai-agent. |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using some custom CNI's. |
| enableTopologySpreadConstraints | bool | `false` |  |
| fullnameOverride | string | `"castai-cluster-controller"` |  |
| hostNetwork.enabled | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/cluster-controller"` |  |
| image.tag | string | `""` | Tag is set using Chart.yaml appVersion field. |
| imagePullSecrets | object | `{}` |  |
| k8sApiClient | object | `{"rateLimit":{"burst":200,"qps":100}}` | Settings for configuring k8s client used in castai-cluster-controller. |
| leaderElectionEnabled | bool | `true` | When running 2+ replicas of castai-cluster-controller only one should work as a leader. |
| leaderElectionLeaseDuration | string | `"15s"` |  |
| leaderElectionRenewDeadline | string | `"10s"` |  |
| monitor.resources.requests.cpu | string | `"100m"` |  |
| monitor.resources.requests.memory | string | `"128Mi"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pdbMinAvailable | int | `1` |  |
| podAnnotations | object | `{}` | Annotations added to each pod. |
| podLabels | object | `{}` |  |
| priorityClass | object | `{"enabled":true,"name":"system-cluster-critical"}` | K8s priority class of castai-cluster-controller |
| replicas | int | `2` | Number of replicas for castai-cluster-controller deployment. |
| resources.limits.memory | string | `"1Gi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"100Mi"` |  |
| securityContext | object | `{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}` | User 65532 is non-root user for gcr distorless images |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"castai-cluster-controller"` |  |
| tolerations | object | `{}` |  |
| topologySpreadConstraints[0].labelSelector.matchLabels."app.kubernetes.io/name" | string | `"castai-cluster-controller"` |  |
| topologySpreadConstraints[0].maxSkew | int | `1` |  |
| topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| trustedCACert | string | `""` | CA certificate to add to the set of root certificate authorities that the client will use when verifying server certificates. |
| trustedCACertSecretRef | string | `""` | Name of secret with CA certificate to be added to the set of root certificate authorities that the client will use when verifying server certificates. trustedCACert and trustedCACertSecretRef are mutually exclusive. The referenced secret must provide the certificate in .data["TLS_CA_CERT_FILE"]. |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Controls `deployment.spec.strategy` field. |
| workloadManagement | object | `{"enabled":false}` | Settings for managing deployments and other pod controllers. |
| workloadManagement.enabled | bool | `false` | Adds permissions to patch deployments. |