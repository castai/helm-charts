# castai-db-optimizer

![Version: 0.63.3](https://img.shields.io/badge/Version-0.63.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| dnsConfig | object | `{}` | Pod DNS configuration. Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | Pod DNS policy. WARNING: If using dnsPolicy "None" with custom nameservers, ensure they can resolve cluster-internal DNS names (*.svc.cluster.local) for peer discovery to work correctly with the headless service. Ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| endpoints | list | `[{"hostname":"sample-db-hostname","name":null,"port":5433,"serviceDiscovery":{"dns_lookup_family":"ALL","dns_refresh_rate":"5000ms","respect_dns_ttl":true,"type":"LOGICAL_DNS"},"servicePort":5432,"targetPort":5432}]` | A list of upstream database endpoints |
| endpoints[0].hostname | string | `"sample-db-hostname"` | Hostname of the upstream database instance. |
| endpoints[0].name | string | `nil` | Name of the service. If this value is not empty, then additional cluster IP service will be deployed, using provided name as a suffix |
| endpoints[0].port | int | `5433` | Port for the endpoint on DBO pod. |
| endpoints[0].serviceDiscovery | object | `{"dns_lookup_family":"ALL","dns_refresh_rate":"5000ms","respect_dns_ttl":true,"type":"LOGICAL_DNS"}` | Envoy service discovery settings. Ref: https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/cluster/v3/cluster.proto.html |
| endpoints[0].serviceDiscovery.type | string | `"LOGICAL_DNS"` | The service discovery type to use for resolving the cluster. Available options: LOGICAL_DNS and STRICT_DNS. Ref: https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/service_discovery |
| endpoints[0].servicePort | int | `5432` | Port of the named service |
| endpoints[0].targetPort | int | `5432` | Port of the upstream database instance. |
| nodeSelector | object | `{}` | Pod node selector rules. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| pgdog.config | object | `{"checkout_timeout":10000,"connect_timeout":5000,"default_pool_size":10,"healthcheck_interval":30000,"healthcheck_timeout":5000,"idle_healthcheck_delay":5000,"idle_healthcheck_interval":30000,"log_connections":false,"log_disconnections":false,"passthrough_auth":"enabled_plain","pooler_mode":"transaction","prepared_statements":"extended_anonymous","prepared_statements_limit":5000,"query_cache_limit":500,"query_parser_enabled":true,"rollback_timeout":5000,"shutdown_timeout":60000,"tls_certificate":"/etc/ssl/certs/ssl-cert-snakeoil.pem","tls_private_key":"/etc/ssl/private/ssl-cert-snakeoil.key","tls_verify":"prefer","workers":10}` | Pgdog general configuration settings. Corresponds to [general] section in pgdog.toml: https://docs.pgdog.dev/configuration/pgdog.toml/general/. |
| pgdog.config.checkout_timeout | int | `10000` | Maximum amount of time a client is allowed to wait for a connection from the pool (in milliseconds) |
| pgdog.config.connect_timeout | int | `5000` | Maximum amount of time to allow for PgDog to create a connection to Postgres (in milliseconds) |
| pgdog.config.default_pool_size | int | `10` | Default maximum number of server connections per database pool |
| pgdog.config.healthcheck_interval | int | `30000` | Frequency of healthchecks performed by PgDog to ensure connections provided to clients from the pool are working (in milliseconds) |
| pgdog.config.healthcheck_timeout | int | `5000` | Health check timeout in milliseconds (custom field, not in official pgdog docs) |
| pgdog.config.idle_healthcheck_delay | int | `5000` | Delay running idle healthchecks at PgDog startup to give databases (and pools) time to spin up (in milliseconds) |
| pgdog.config.idle_healthcheck_interval | int | `30000` | Frequency of healthchecks performed by PgDog on idle connections (in milliseconds) |
| pgdog.config.log_connections | bool | `false` | If enabled, log every time a user creates a new connection to PgDog |
| pgdog.config.log_disconnections | bool | `false` | If enabled, log every time a user disconnects from PgDog |
| pgdog.config.passthrough_auth | string | `"enabled_plain"` | Enables/disable passthrough authentication. Option: "enabled_plain", "disabled". Although PgDog supports just "enabled", we do not as communication is container-container and using TLS would only add unnecessary overhead |
| pgdog.config.pooler_mode | string | `"transaction"` | Default pooler mode to use for database pools. Options: "session", "transaction", "statement" |
| pgdog.config.prepared_statements | string | `"extended_anonymous"` | Enables prepared statement support with varying levels of rewriting capability. Options: "disabled", "extended", "extended_anonymous", "full" |
| pgdog.config.prepared_statements_limit | int | `5000` | Maximum number of prepared statements that can be cached per connection |
| pgdog.config.query_cache_limit | int | `500` | Maximum number of entries in the query cache |
| pgdog.config.query_parser_enabled | bool | `true` | Force-enable query parsing for advanced features like advisory locks in non-sharded databases |
| pgdog.config.rollback_timeout | int | `5000` | How long to allow for ROLLBACK queries to run on server connections with unfinished transactions (in milliseconds) |
| pgdog.config.shutdown_timeout | int | `60000` | How long to wait for active clients to finish transactions when shutting down (in milliseconds) |
| pgdog.config.tls_certificate | string | `"/etc/ssl/certs/ssl-cert-snakeoil.pem"` | Path to the TLS certificate PgDog will use to setup TLS connections with clients |
| pgdog.config.tls_private_key | string | `"/etc/ssl/private/ssl-cert-snakeoil.key"` | Path to the TLS private key PgDog will use to setup TLS connections with clients |
| pgdog.config.tls_verify | string | `"prefer"` | Determines how TLS connections to Postgres servers are handled. Options: "none", "prefer", "verify_ca", "verify_full" |
| pgdog.config.workers | int | `10` | Count of Tokio threads spawned at startup; recommended setting is two per virtual CPU |
| pgdog.enabled | bool | `false` | Enable pgdog connection pooler sidecar |
| pgdog.password | string | `""` | Pgdog password (plain string). Mutually exclusive with usersSecretRef |
| pgdog.resources.cpu | string | `"500m"` |  |
| pgdog.resources.memory | string | `"256Mi"` |  |
| pgdog.user | string | `""` | Pgdog user (plain string). Mutually exclusive with usersSecretRef |
| pgdog.usersSecretRef | string | `""` | Reference to existing secret containing users.toml file. Mutually exclusive with user/password The secret must contain a key named "users.toml" with the pgdog users configuration |
| pgdogImage.pullPolicy | string | `"IfNotPresent"` |  |
| pgdogImage.repository | string | `"ghcr.io/pgdogdev/pgdog"` |  |
| pgdogImage.tag | string | `""` |  |
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
| queryProcessor.queryCacheBytes | int | `524288000` | Default query-processor query cache byte size. |
| queryProcessor.queryCacheSize | int | `100000` | Default query-processor query cache item size. |
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
