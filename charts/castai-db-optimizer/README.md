# castai-db-optimizer

![Version: 0.25.0](https://img.shields.io/badge/Version-0.25.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

CAST AI database cache deployment.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"provisioner.cast.ai/managed-by","operator":"In","values":["cast.ai"]}]},"weight":100}],"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"NotIn","values":["windows"]},{"key":"kubernetes.io/arch","operator":"In","values":["amd64"]}]}]}},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["APP_NAME"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Pod affinity rules. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| apiKey | string | `""` | Token to be used for authorizing access to the CAST AI API.  |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing DBO access to the API apiKey and apiKeySecretRef are mutually exclusive The referenced secret must provide the token in .data["API_KEY"]. |
| apiURL | string | `"api.cast.ai"` | URL to the CAST AI API server. |
| cacheGroupID | string | `""` | ID of the cache group for which cache configuration should be pulled.  |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| endpoints | list | `[{"hostname":"sample-db-hostname","name":null,"port":5433,"servicePort":5432,"targetPort":5432}]` | A list of upstream database endpoints |
| endpoints[0].hostname | string | `"sample-db-hostname"` | Hostname of the upstream database instance. |
| endpoints[0].name | string | `nil` | Name of the service. If this value is not empty, then additional cluster IP service will be deployed, using provided name as a suffix |
| endpoints[0].port | int | `5433` | Port for the endpoint on DBO pod. |
| endpoints[0].servicePort | int | `5432` | Port of the named service |
| endpoints[0].targetPort | int | `5432` | Port of the upstream database instance. |
| nodeSelector | object | `{}` | Pod node selector rules. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| podAnnotations | object | `{}` | Extra annotations to add to the pod. |
| podLabels | object | `{}` | Extra labels to add to the pod. |
| protocol | string | `"PostgreSQL"` | Specifies database protocol to be used for communication and query parsing. |
| proxy.concurrency | int | `12` | Number of parallel processing streams. This needs to be balanced with cpu resources for proxy and QP. |
| proxy.connectionLimits | object | `{"maxConnections":1024,"maxPendingRequests":1024,"maxRequests":1024,"maxRetries":3}` | Envoy upstream connection limits, numbers given are the envoy defaults. |
| proxy.dataStorageMedium | string | `"Memory"` | Defines "emptyDir.medium" value for data storage volume. Set to "Memory" for tmpfs disk |
| proxy.dnsLookupFamily | string | `"V4_PREFERRED"` | DNS lookup mode when communicating to outside. will prioritize IPV4 addresses. change to V6_ONLY to use v6 addresses instead. |
| proxy.drainTimeSeconds | int | `60` | Default drain time in seconds. |
| proxy.evictionThreadPeriodMs | int | `100` | The period of the evictions thread. |
| proxy.evictionThreshold | float | `0.5` | Ratio of used available bytes or entries from which we start evicting. |
| proxy.livenessProbeEnabled | bool | `true` | Ensure proxy is alive and healthy. |
| proxy.logLevel | string | `"filter:info"` | Default proxy log level. |
| proxy.networkDebug | bool | `false` | Extra network debug logging. |
| proxy.readinessProbeEnabled | bool | `true` | Ensure proxy has retrieved initial cache configuration before accepting connections. |
| proxy.statsThreadPeriodMs | int | `1000` | The period of the stats thread. |
| proxy.stopCachingThreshold | float | `0.95` | Ratio of used available bytes or entries from which we stop caching. |
| proxy.writeBatchDelayMs | int | `100` | The delay of one batch for writing. |
| proxy.writeBatchSize | int | `100` | The size of one batch for writing. |
| proxyImage.pullPolicy | string | `"IfNotPresent"` |  |
| proxyImage.repository | string | `"us-docker.pkg.dev/castai-hub/library/dbo-proxy"` |  |
| proxyImage.tag | string | `""` |  |
| queryProcessor.concurrency | int | `10` | Number of worker threads. This should ideally be tuned around 1.5 - 2x times more than expected amount of CPU usage. |
| queryProcessor.logLevel | string | `"warn"` | Default query-processor log level. |
| queryProcessor.queryCacheSize | int | `100000` | Default query-processor query cache size. |
| queryProcessorImage.pullPolicy | string | `"IfNotPresent"` |  |
| queryProcessorImage.repository | string | `"us-docker.pkg.dev/castai-hub/library/query-processor"` |  |
| queryProcessorImage.tag | string | `""` |  |
| replicas | int | `2` |  |
| resources.proxy.cacheDbSizeBytes | int | `1000000000` | max allowed database size in disk. |
| resources.proxy.cpu | string | `"500m"` |  |
| resources.proxy.ephemeralStorage | string | `"10Gi"` | defines how much of proxy container disk space is allocated for cache. |
| resources.proxy.maxCacheEntries | int | `1000000000` | maximum number of entries to keep in the proxy. |
| resources.proxy.memoryLimit | string | `"2Gi"` |  |
| resources.proxy.memoryRequest | string | `"2Gi"` |  |
| resources.queryProcessor.cpu | string | `"2"` |  |
| resources.queryProcessor.memory | string | `"1Gi"` |  |
| tolerations | object | `{}` | Pod toleration rules. Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| upstreamPostgresHostname | string | `""` | deprecated: Hostname of the upstream Postgres instance. |
| upstreamPostgresPort | int | `5432` | deprecated: Port of the upstream Postgres instance. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
