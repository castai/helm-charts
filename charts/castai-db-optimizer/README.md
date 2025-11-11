# castai-db-optimizer

![Version: 0.49.6](https://img.shields.io/badge/Version-0.49.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| pgcatImage.pullPolicy | string | `"IfNotPresent"` |  |
| pgcatImage.repository | string | `"us-docker.pkg.dev/castai-hub/library/dbo-pooling-pgcat"` |  |
| pgcatImage.tag | string | `"v1.2.0-embedded-ssl"` |  |
| podAnnotations | object | `{}` | Extra annotations to add to the pod. |
| podLabels | object | `{}` | Extra labels to add to the pod. |
| pooling.banTime | int | `60` | Ban time in seconds |
| pooling.connectTimeout | int | `1000` | Connect timeout in milliseconds |
| pooling.credentialsSecretRef | string | `""` | Name of secret with username for database authentication |
| pooling.databases | list | `[]` | List of database names to create pools for (required when pooling is enabled) |
| pooling.defaultRole | string | `"any"` | Default role (any, primary, replica) |
| pooling.enabled | bool | `false` | Enable connection pooling sidecar. |
| pooling.healthcheckDelay | int | `30000` | Health check delay in milliseconds |
| pooling.healthcheckTimeout | int | `1000` | Health check timeout in milliseconds |
| pooling.idleTimeout | int | `30000` | Idle timeout in milliseconds |
| pooling.listenAddress | string | `"0.0.0.0"` | Listen address for PgCat |
| pooling.loadBalancingMode | string | `"random"` | Load balancing mode (random or loc) |
| pooling.logClientConnections | bool | `false` | Log client connections |
| pooling.logClientDisconnections | bool | `false` | Log client disconnections |
| pooling.logLevel | string | `"info"` | Pooling log level, must be one of error, warn, info, debug, trace, off |
| pooling.minPoolSize | int | `5` | Minimum pool size per user |
| pooling.password | string | `""` | Password for database authentication |
| pooling.poolMode | string | `"transaction"` | Pool mode (session or transaction) |
| pooling.poolSize | int | `20` | Maximum pool size per user |
| pooling.preparedStatementsCacheSize | int | `1000` | Size of prepared statements cache |
| pooling.serverLifetime | int | `86400000` | Server lifetime in milliseconds |
| pooling.serverTLS | bool | `true` | Enable TLS for server connections |
| pooling.tlsCertificateFilePath | string | `""` | Path to TLS certificate for server connections (PEM format) |
| pooling.tlsPrivateKeyFilePath | string | `""` | Path to TLS private key for server connections (PEM format) |
| pooling.username | string | `""` | Username for database authentication |
| pooling.verifyServerCertificate | bool | `false` | Verify server certificate when using TLS |
| protocol | string | `"PostgreSQL"` | Specifies database protocol to be used for communication and query parsing. |
| proxy.cache.cacheShards | int | `64` | Number of cache shards _must_ be power of 2 |
| proxy.cache.cacheSizeBytes | int | `2147483648` | Maximum cache size in bytes, _should_ be divisible by cacheShards |
| proxy.cache.pendingShards | int | `64` | Number of in-flight cache shards _must_ be power of 2 |
| proxy.cache.pendingSizeBytes | int | `134217728` | Maximum size of in-flight cache entries, _should_ be divisible by pendingShards |
| proxy.concurrency | int | `12` | Number of parallel processing streams. This needs to be balanced with cpu resources for proxy and QP. |
| proxy.connectionLimits | object | `{"maxConnections":10000,"maxPendingRequests":1024,"maxRequests":1024,"maxRetries":3}` | Envoy upstream connection limits, numbers given are the envoy defaults. |
| proxy.coredumpCollectionMode | string | `"None"` | Disable core dump collection by default |
| proxy.dataStorageMedium | string | `"Memory"` | Defines "emptyDir.medium" value for data storage volume. Set to "Memory" for tmpfs disk |
| proxy.dnsLookupFamily | string | `"V4_PREFERRED"` | DNS lookup mode when communicating to outside. will prioritize IPV4 addresses. change to V6_ONLY to use v6 addresses instead. |
| proxy.drainPreHook | int | `2` | Predrain timeout in seconds. |
| proxy.drainTimeSeconds | int | `60` | Default drain time in seconds. |
| proxy.evictionThreadPeriodMs | int | `100` | The period of the evictions thread. |
| proxy.evictionThreshold | float | `0.5` | Ratio of used available bytes or entries from which we start evicting. |
| proxy.experimentalCache | bool | `false` | Enable experimental cache in dbo proxy. |
| proxy.livenessProbeEnabled | bool | `true` | Ensure proxy is alive and healthy. |
| proxy.logLevel | string | `"filter:info"` | Default proxy log level. |
| proxy.networkDebug | bool | `false` | Extra network debug logging. |
| proxy.statsThreadPeriodMs | int | `1000` | The period of the stats thread. |
| proxy.stopCachingThreshold | float | `0.95` | Ratio of used available bytes or entries from which we stop caching. |
| proxy.tlsSecretName | string | `nil` | Name of a Kubernetes TLS Secret that contains the key pair to use for configuring TLS in the proxy. If not set, defaults to using a built-in key pair. |
| proxy.writeBatchDelayMs | int | `100` | The delay of one batch for writing. |
| proxy.writeBatchSize | int | `100` | The size of one batch for writing. |
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
| resources.proxy.cacheDbSizeBytes | int | `1000000000` | max allowed database size in disk. |
| resources.proxy.cpu | string | `"500m"` |  |
| resources.proxy.maxCacheEntries | int | `1000000000` | maximum number of entries to keep in the proxy. |
| resources.proxy.memoryLimit | string | `"2Gi"` |  |
| resources.proxy.memoryRequest | string | `"2Gi"` |  |
| resources.queryProcessor.cpu | string | `"2"` |  |
| resources.queryProcessor.memory | string | `"1Gi"` |  |
| serviceAccountName | string | `""` | The name of the service account to be used by the pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| tolerations | object | `{}` | Pod toleration rules. Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| upstreamPostgresHostname | string | `""` | deprecated: Hostname of the upstream Postgres instance. |
| upstreamPostgresPort | int | `5432` | deprecated: Port of the upstream Postgres instance. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
