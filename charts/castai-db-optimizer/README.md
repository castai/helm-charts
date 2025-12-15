# castai-db-optimizer

![Version: 0.53.0](https://img.shields.io/badge/Version-0.53.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

CAST AI database cache deployment.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"provisioner.cast.ai/managed-by","operator":"In","values":["cast.ai"]}]},"weight":100}],"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"NotIn","values":["windows"]},{"key":"kubernetes.io/arch","operator":"In","values":["amd64"]}]}]}},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["APP_NAME"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Pod affinity rules. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| apiKey | string | `""` | Token to be used for authorizing access to the CAST AI API.  |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing DBO access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| apiURL | string | `"api.cast.ai"` | URL to the CAST AI API server. |
| cacheGroupID | string | `""` | ID of the cache group for which cache configuration should be pulled.  |
| cloudSqlProxy.autoIamAuthn | bool | `false` | Have the proxy connect with Automatic IAM authentication |
| cloudSqlProxy.basePort | int | `10000` | Starting number from which unique ports are sequentially assigned to each upstream Cloud SQL instance |
| cloudSqlProxy.enabled | bool | `false` | Enable Cloud SQL Proxy sidecar |
| cloudSqlProxy.privateIp | bool | `false` | Have the proxy connect over private IP if connecting from a VPC-native GKE cluster |
| cloudSqlProxyImage.pullPolicy | string | `"IfNotPresent"` |  |
| cloudSqlProxyImage.repository | string | `"gcr.io/cloud-sql-connectors/cloud-sql-proxy"` |  |
| cloudSqlProxyImage.tag | string | `""` |  |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| endpoints | list | `[{"hostname":"sample-db-hostname","name":null,"port":5433,"serviceDiscovery":{"dns_lookup_family":"ALL","dns_refresh_rate":"5000ms","respect_dns_ttl":true,"type":"LOGICAL_DNS"},"servicePort":5432,"targetPort":5432}]` | A list of upstream database endpoints |
| endpoints[0].hostname | string | `"sample-db-hostname"` | Hostname of the upstream database instance. |
| endpoints[0].name | string | `nil` | Name of the service. If this value is not empty, then additional cluster IP service will be deployed, using provided name as a suffix |
| endpoints[0].port | int | `5433` | Port for the endpoint on DBO pod. |
| endpoints[0].serviceDiscovery | object | `{"dns_lookup_family":"ALL","dns_refresh_rate":"5000ms","respect_dns_ttl":true,"type":"LOGICAL_DNS"}` | Envoy service discovery settings. Ref: https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/cluster/v3/cluster.proto.html |
| endpoints[0].serviceDiscovery.type | string | `"LOGICAL_DNS"` | The service discovery type to use for resolving the cluster. Available options: LOGICAL_DNS and STRICT_DNS. Ref: https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/service_discovery |
| endpoints[0].servicePort | int | `5432` | Port of the named service |
| endpoints[0].targetPort | int | `5432` | Port of the upstream database instance. |
| nodeSelector | object | `{}` | Pod node selector rules. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| podAnnotations | object | `{}` | Extra annotations to add to the pod. |
| podLabels | object | `{}` | Extra labels to add to the pod. |
| protocol | string | `"PostgreSQL"` | Specifies database protocol to be used for communication and query parsing. |
| proxy.cache | object | `{"cacheShards":0,"cacheSizeBytes":2147483648,"pendingShards":0,"pendingSizeBytes":134217728}` | Cache configuration |
| proxy.cache.cacheShards | int | `0` | Number of cache shards _must_ be power of 2. Use 0 to auto-calculate based on concurrency. |
| proxy.cache.cacheSizeBytes | int | `2147483648` | Maximum cache size in bytes, _should_ be divisible by cacheShards |
| proxy.cache.pendingShards | int | `0` | Number of in-flight cache shards _must_ be power of 2.  Use 0 to auto-calculate based on concurrency. |
| proxy.cache.pendingSizeBytes | int | `134217728` | Maximum size of in-flight cache entries, _should_ be divisible by pendingShards |
| proxy.concurrency | int | `0` | Number of parallel processing streams. Use 0 to auto-calculate based on CPU limits. |
| proxy.connectionLimits | object | `{"maxConnections":10000,"maxPendingRequests":1024,"maxRequests":1024,"maxRetries":3}` | Envoy upstream connection limits, numbers given are the envoy defaults. |
| proxy.coredumpCollectionMode | string | `"None"` | Disable core dump collection by default |
| proxy.dataStorageMedium | string | `"Memory"` | Defines "emptyDir.medium" value for data storage volume. Set to "Memory" for tmpfs disk |
| proxy.dnsLookupFamily | string | `"V4_PREFERRED"` | DNS lookup mode when communicating to outside. will prioritize IPV4 addresses. change to V6_ONLY to use v6 addresses instead. |
| proxy.drainPreHook | int | `2` | Predrain timeout in seconds. |
| proxy.drainTimeSeconds | int | `60` | Default drain time in seconds. |
| proxy.logLevel | string | `"filter:info"` | Default proxy log level. |
| proxy.networkDebug | bool | `false` | Extra network debug logging. |
| proxy.tlsSecretName | string | `nil` | Name of a Kubernetes TLS Secret that contains the key pair to use for configuring TLS in the proxy. If not set, defaults to using a built-in key pair. |
| proxyImage.pullPolicy | string | `"IfNotPresent"` |  |
| proxyImage.repository | string | `"us-docker.pkg.dev/castai-hub/library/dbo-proxy"` |  |
| proxyImage.tag | string | `""` |  |
| queryProcessor.concurrency | int | `10` | Number of worker threads. This should ideally be tuned around 1.5 - 2x times more than expected amount of CPU usage. |
| queryProcessor.debug | bool | `false` | Enable additional debugging features to aid troubleshooting. |
| queryProcessor.logLevel | string | `"warn"` | Default query-processor log level. |
| queryProcessor.queryCacheSize | int | `100000` | Default query-processor query cache size. |
| queryProcessorImage.pullPolicy | string | `"IfNotPresent"` |  |
| queryProcessorImage.repository | string | `"us-docker.pkg.dev/castai-hub/library/query-processor"` |  |
| queryProcessorImage.tag | string | `""` |  |
| replicas | int | `2` |  |
| resources.proxy.cpu | string | `"500m"` |  |
| resources.proxy.memoryLimit | string | `"2Gi"` |  |
| resources.proxy.memoryRequest | string | `"2Gi"` |  |
| resources.queryProcessor.cpu | string | `"2"` |  |
| resources.queryProcessor.memoryLimit | string | `"1Gi"` |  |
| resources.queryProcessor.memoryRequest | string | `"1Gi"` |  |
| service.trafficDistribution | string | `""` | Traffic distribution policy for the service. Set to "PreferClose" to reduce inter-zone traffic. Requires Kubernetes 1.31+. Ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#traffic-distribution |
| serviceAccountName | string | `""` | The name of the service account to be used by the pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| tolerations | object | `{}` | Pod toleration rules. Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| topologySpreadConstraints | list | `[]` | Pod topology spread constraints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| workloadsAnnotations | string | `nil` | CAST.AI workload optimization annotations. Leave as null to apply default configuration with CPU minimums derived from resources.queryProcessor.cpu and resources.proxy.cpu. Set to {} (empty map) to disable workload annotations entirely. Set to custom values to override with your own annotations. Ref: https://docs.cast.ai/docs/workload-autoscaling |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
