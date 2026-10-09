# castai-db-proxy

![Version: 0.26.0](https://img.shields.io/badge/Version-0.26.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

CAST AI database proxy cache deployment.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"provisioner.cast.ai/managed-by","operator":"In","values":["cast.ai"]}]},"weight":100}],"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"NotIn","values":["windows"]},{"key":"kubernetes.io/arch","operator":"In","values":["amd64","arm64"]}]}]}},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["APP_NAME"]},{"key":"app.kubernetes.io/component","operator":"In","values":["proxy"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Pod affinity rules. |
| apiKey | string | `""` | Token to be used for authorizing access to the CAST AI API. |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing access to the API. apiKey and apiKeySecretRef are mutually exclusive. The referenced secret must provide the token in .data["API_KEY"]. |
| apiURL | string | `"api-grpc.cast.ai"` | URL to the CAST AI gRPC API server. |
| cache.analysisMemoMiB | int | `512` | Memory in MiB each proxy pod may use to remember how it analyzed each SQL statement, so repeated statements skip parsing. Also caps the largest statement it can remember. Raise it if the pod has spare memory and the workload sends many distinct or very large statements. |
| cache.defaultTTLSecs | int | `300` | Default TTL for cached results in seconds. |
| cluster.enabled | bool | `true` | Enable distributed cache cluster mode. |
| cluster.refresh_interval_seconds | int | `10` | Refresh interval of DNS for peer discovery in seconds. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| connection_draining | object | `{"grace_period_seconds":55,"graceful_shutdown_timeout_seconds":5,"pre_stop_sleep_seconds":10}` | Connection draining configuration |
| connection_draining.grace_period_seconds | int | `55` | How long existing connections have to finish after SIGTERM. Must be > 0 |
| connection_draining.graceful_shutdown_timeout_seconds | int | `5` | How long the server waits for runtimes to shut down after the grace period. Must be > 0 |
| connection_draining.pre_stop_sleep_seconds | int | `10` | How long the pod's preStop hook sleeps before SIGTERM is delivered to the proxy. This gives the service endpoint propagation time to complete cluster-wide so no new traffic is routed to the pod while it drains existing connections. Set to 0 to disable. |
| dnsConfig | object | `{}` | Pod DNS configuration. |
| dnsPolicy | string | `""` | Pod DNS policy. |
| endpoints | list | `[]` | Upstream database endpoints. Each entry needs `address` (host:port) and `readonly` (bool). |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/castai/images/db-proxy"` |  |
| image.tag | string | `""` | Overrides the image tag. Defaults to Chart.appVersion. |
| keepalive | object | `{"count":3,"idle_seconds":60,"interval_seconds":10}` | TCP keepalive for client and database connections. Probing is the only way to tell a connection whose far end vanished *without closing* (an evicted pod, a lost node, a killed database instance etc.) from one that is merely idle. Without it the proxy would wait on a read that will never complete, holding the connection and the database session behind it until the pod restarts. |
| keepalive.count | int | `3` | Unanswered probes before the connection is dropped. |
| keepalive.idle_seconds | int | `60` | How long a connection may sit idle before the first probe. |
| keepalive.interval_seconds | int | `10` | Gap between probes once they start. |
| logLevel | string | `"info"` | Application log level. Supports "trace", "debug", "info", "warn", "error" |
| nodeSelector | object | `{}` | Pod node selector rules. |
| operationalMetricsFlushIntervalSeconds | int | `15` | Interval in seconds to flush operational metrics. Must be greater than 0. |
| organizationID | string | `""` | ID of the organization. |
| podAnnotations | object | `{}` | Extra annotations to add to the pod. |
| podLabels | object | `{}` | Extra labels to add to the pod. |
| pooling.configManager.discovery | object | `{"refresh_interval_seconds":10}` | Peer discovery settings. |
| pooling.configManager.discovery.refresh_interval_seconds | int | `10` | Refresh interval of DNS for peer discovery in seconds. |
| pooling.configManager.image.pullPolicy | string | `"IfNotPresent"` |  |
| pooling.configManager.image.repository | string | `"ghcr.io/castai/images/db-pooling"` |  |
| pooling.configManager.image.tag | string | `""` |  |
| pooling.configManager.port | int | `50051` | gRPC listen port for the config manager. |
| pooling.configManager.report_metrics_frequency_seconds | int | `15` | Frequency in which pooling metrics are reported in seconds. |
| pooling.configManager.resources.cpu | string | `"10m"` |  |
| pooling.configManager.resources.memoryLimit | string | `"32Mi"` |  |
| pooling.configManager.resources.memoryRequest | string | `"32Mi"` |  |
| pooling.databases | list | `["postgres"]` | Pre-configured database names. |
| pooling.enabled | bool | `false` | Deploy the pooling config manager. |
| pooling.metricsPort | int | `9090` | Pooler metrics port. |
| pooling.pgdog | object | `{"admin":{"name":"pgdog_admin","password":"admin","user":"admin"},"config":{},"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/castai/images/pgdogdev/pgdog","tag":""},"logLevel":"warn","port":5432,"resources":{"cpu":"1","memoryLimit":"1Gi","memoryRequest":"1Gi"}}` | Configure the PgDog section to deploy PgDog as the pooler. |
| pooling.pgdog.config | object | `{}` | PgDog [general] config overrides. Merged on top of template defaults (health checks, timeouts, passthrough_auth, log settings). Any key-value pair added here will be rendered into pgdog.toml. See https://docs.pgdog.dev/configuration/pgdog.toml/general/ |
| pooling.pgdog.port | int | `5432` | Pooler listen port. Proxy connects to the pooler on this port. |
| pooling.proxySql | object | `{"config":{"auto_increment_delay_multiplex":5,"connect_timeout_server":5000,"default_query_timeout":36000000,"free_connections_pct":5,"have_compress":true,"max_backend_connections":100,"max_connections":2048,"multiplexing":true,"stacksize":1048576,"threads":4},"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/castai/images/proxysql/proxysql","tag":""},"ports":{"readOnly":6402,"readWrite":6401},"resources":{"cpu":"1","memoryLimit":"1Gi","memoryRequest":"1Gi"},"userSecretRef":""}` | Configure the ProxySQL section to deploy ProxySQL as the pooler (MySQL only). Mutually exclusive with pgdog. Requires protocol: "MySQL". |
| pooling.proxySql.ports.readOnly | int | `6402` | Listening port for read-only connections. |
| pooling.proxySql.ports.readWrite | int | `6401` | Listening port for read-write connections. |
| pooling.proxySql.userSecretRef | string | `""` | Name of an existing Secret containing upstream DB user. The secret must contain the username and the password fields. |
| pooling.replicas | int | `2` | Number of pooler replicas. |
| ports.cluster | int | `9050` | Cluster peer communication port. |
| ports.metrics | int | `9090` | Prometheus metrics port the proxy listens on. Not exposed through the proxy services; scrape the pods directly, e.g. via podAnnotations:   podAnnotations:     prometheus.io/scrape: "true"     prometheus.io/port: "9090" |
| ports.readOnly | int | `6142` | Port the proxy listens on for read-only connections. Only used when a read-only upstream endpoint is configured: clients then connect through the `<release>-ro` service, which exposes the protocol's default port targeting this port. |
| ports.readWrite | int | `6141` | Port the proxy listens on for read-write connections. Clients connect through the release service, which exposes the protocol's default port (5432 PostgreSQL, 3306 MySQL, 1521 Oracle) targeting this port. |
| protocol | string | `"PostgreSQL"` | Database protocol. |
| proxyID | string | `""` | ID of this proxy instance. |
| queryMetricsBufferSize | int | `50000` | Maximum query metrics queued before new ones are dropped |
| queryMetricsFlushIntervalSeconds | int | `5` | Interval in seconds to flush query metrics. Must be greater than 0. |
| queryMetricsMaxConcurrentRequests | int | `4` | Maximum query metric requests in flight at once. The dial for metric throughput |
| replicas | int | `2` |  |
| resources.cpu | string | `"2"` |  |
| resources.memoryLimit | string | `"2Gi"` |  |
| resources.memoryRequest | string | `"2Gi"` |  |
| rollingUpdate | object | `{"maxSurge":"100%","maxUnavailable":0}` | Rolling update strategy configuration. |
| rollingUpdate.maxSurge | string | `"100%"` | Maximum number of pods that can be created above the desired number of pods during an update. |
| rollingUpdate.maxUnavailable | int | `0` | Maximum number of pods that can be unavailable during an update. |
| serverThreads | string | `""` | Worker threads for each proxy listener that serves traffic. Leave empty to derive from resources.cpu, rounded up (minimum 1). Set explicitly only to override that. Background services are fixed at one thread each and are unaffected. |
| service.annotations | object | `{}` | Annotations added to the client-facing proxy services (read-write and read-only), on top of commonAnnotations. Use these to configure your cloud's load balancer exactly as your cloud provider's documentation describes. Examples (GKE):  annotations:    networking.gke.io/load-balancer-type: "Internal"    # Optional: allow clients from other regions in the same VPC    # networking.gke.io/internal-load-balancer-allow-global-access: "true"    # Optional: pin to a reserved internal IP (reserve it in the same subnet first)    # networking.gke.io/load-balancer-ip-addresses: "my-reserved-ip-name"    # Optional: place the LB in a specific subnet    # networking.gke.io/internal-load-balancer-subnet: "my-subnet" Examples (EKS, AWS Load Balancer Controller -> NLB):  annotations:    service.beta.kubernetes.io/aws-load-balancer-type: "external"    service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"    # Register pod IPs directly (needs the VPC CNI) instead of node ports    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"    # Optional: attach a security group to the NLB and manage access there    # service.beta.kubernetes.io/aws-load-balancer-security-groups: "sg-0123456789abcdef0"    # Optional: pin to specific subnets (otherwise auto-discovered via subnet tags)    # service.beta.kubernetes.io/aws-load-balancer-subnets: "subnet-aaa,subnet-bbb"    # Optional: fixed private IPs, one per subnet (requires the subnets annotation)    # service.beta.kubernetes.io/aws-load-balancer-private-ipv4-addresses: "10.0.1.10,10.0.2.10"    # Optional: preserve the client IP when using ip targets (off by default)    # service.beta.kubernetes.io/aws-load-balancer-target-group-attributes: "preserve_client_ip.enabled=true" |
| service.externalTrafficPolicy | string | `""` | External traffic policy ("Cluster" or "Local"). "Local" preserves the client source IP. Only meaningful when type is LoadBalancer or NodePort. |
| service.loadBalancerSourceRanges | list | `[]` | CIDRs allowed to reach the proxy services when type is LoadBalancer. Leave empty to allow all. On GKE this restricts the LB firewall; on EKS prefer the aws-load-balancer-security-groups annotation (NLBs do not support source ranges). |
| service.trafficDistribution | string | `"PreferClose"` | Traffic distribution policy for the proxy services (read-write and read-only). Set to "PreferClose" to reduce inter-zone traffic. Requires Kubernetes 1.31+. |
| service.type | string | `""` | Type of the client-facing proxy services (read-write and read-only). Set to "LoadBalancer" to expose the proxy through a cloud load balancer. Metrics are not exposed through these services; scrape the pods directly (see ports.metrics). Cloud-specific load balancer behavior is configured through `service.annotations` -- set them 1:1 as your cloud's documentation describes. |
| serviceAccountName | string | `""` | The name of the service account to be used by the pod. |
| tls.secretName | string | `""` | Name of a TLS secret (tls.crt/tls.key) to override the built-in self-signed cert. |
| tolerations | list | `[]` | Pod toleration rules. |
| topologySpreadConstraints | list | `[]` | Pod topology spread constraints. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
