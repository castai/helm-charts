# castai-cluster-controller

Cluster controller is responsible for handling certain Kubernetes actions such as draining and deleting nodes, adding labels, approving CSR requests.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{"LOG_LEVEL":"5"}` | Env variables passed to castai-cluster-controller. |
| affinity | object | `{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"NotIn","values":["windows"]}]}]}},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["castai-cluster-controller"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Pod affinity rules. Don't schedule application on windows node Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| castai | object | `{"apiKey":"","apiKeySecretRef":"","apiURL":"https://api.cast.ai","clusterID":""}` | CAST AI API configuration. |
| castai.apiKey | string | `""` | Token to be used for authorizing agent access to the CASTAI API. |
| castai.apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing agent access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| castai.apiURL | string | `"https://api.cast.ai"` | CASTAI public api url. |
| castai.clusterID | string | `""` | CASTAI Cluster unique identifier. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| createNamespace | bool | `false` | By default namespace is expected to be created by castai-agent. |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using some custom CNI's. |
| fullnameOverride | string | `"castai-cluster-controller"` |  |
| hostNetwork.enabled | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/cluster-controller"` |  |
| image.tag | string | `""` | Tag is set using Chart.yaml appVersion field. |
| imagePullSecrets | object | `{}` |  |
| k8sApiClient | object | `{"rateLimit":{"burst":150,"qps":25}}` | Settings for configuring k8s client used in castai-cluster-controller. |
| leaderElectionEnabled | bool | `true` | When running 2+ replicas of castai-cluster-controller only one should work as a leader. |
| leaderElectionLeaseDuration | string | `"15s"` |  |
| leaderElectionRenewDeadline | string | `"10s"` |  |
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
| securityContext | object | `{}` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"castai-cluster-controller"` |  |
| tolerations | object | `{}` |  |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Controls `deployment.spec.strategy` field. |
| workloadManagement | object | `{"enabled":false}` | Settings for managing deployments and other pod controllers. |
| workloadManagement.enabled | bool | `false` | Adds permissions to patch deployments. |