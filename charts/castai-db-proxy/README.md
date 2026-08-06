# castai-db-proxy

![Version: 0.9.0](https://img.shields.io/badge/Version-0.9.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

CAST AI database proxy cache deployment.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"provisioner.cast.ai/managed-by","operator":"In","values":["cast.ai"]}]},"weight":100}],"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"NotIn","values":["windows"]},{"key":"kubernetes.io/arch","operator":"In","values":["amd64","arm64"]}]}]}},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["APP_NAME"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Pod affinity rules. |
| apiKey | string | `""` | Token to be used for authorizing access to the CAST AI API. |
| apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing access to the API. apiKey and apiKeySecretRef are mutually exclusive. The referenced secret must provide the token in .data["API_KEY"]. |
| apiURL | string | `"api-grpc.cast.ai"` | URL to the CAST AI gRPC API server. |
| cache.defaultTTLSecs | int | `300` | Default TTL for cached results in seconds. |
| cluster.enabled | bool | `true` | Enable distributed cache cluster mode. |
| cluster.refresh_interval_seconds | int | `10` | Refresh interval of DNS for peer discovery in seconds. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| connection_draining | object | `{"grace_period_seconds":55,"graceful_shutdown_timeout_seconds":5}` | Connection draining configuration |
| connection_draining.grace_period_seconds | int | `55` | How long existing connections have to finish after SIGTERM. Must be > 0 |
| connection_draining.graceful_shutdown_timeout_seconds | int | `5` | How long the server waits for runtimes to shut down after the grace period. Must be > 0 |
| dnsConfig | object | `{}` | Pod DNS configuration. |
| dnsPolicy | string | `""` | Pod DNS policy. |
| endpoints | list | `[]` | Upstream database endpoints. Each entry needs `address` (host:port) and `readonly` (bool). |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/db-proxy"` |  |
| image.tag | string | `""` | Overrides the image tag. Defaults to Chart.appVersion. |
| logLevel | string | `"info"` | Application log level. Supports "trace", "debug", "info", "warn", "error" |
| nodeSelector | object | `{}` | Pod node selector rules. |
| organizationID | string | `""` | ID of the organization. |
| podAnnotations | object | `{}` | Extra annotations to add to the pod. |
| podLabels | object | `{}` | Extra labels to add to the pod. |
| pooling.configManager.discovery | object | `{"refresh_interval_seconds":10}` | Peer discovery settings. |
| pooling.configManager.discovery.refresh_interval_seconds | int | `10` | Refresh interval of DNS for peer discovery in seconds. |
| pooling.configManager.image.pullPolicy | string | `"IfNotPresent"` |  |
| pooling.configManager.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/db-pooling"` |  |
| pooling.configManager.image.tag | string | `""` |  |
| pooling.configManager.port | int | `50051` | gRPC listen port for the config manager. |
| pooling.configManager.resources.cpu | string | `"10m"` |  |
| pooling.configManager.resources.memoryLimit | string | `"32Mi"` |  |
| pooling.configManager.resources.memoryRequest | string | `"32Mi"` |  |
| pooling.databases | list | `["postgres"]` | Pre-configured database names. |
| pooling.enabled | bool | `false` | Deploy the pooling config manager. |
| pooling.metricsPort | int | `9090` | Pooler metrics port. |
| pooling.pgdog | object | `{"admin":{"name":"pgdog_admin","password":"admin","user":"admin"},"config":{},"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/pgdogdev/pgdog","tag":""},"logLevel":"warn","resources":{"cpu":"1","memoryLimit":"1Gi","memoryRequest":"1Gi"}}` | Configure the PgDog section to deploy PgDog as the pooler. |
| pooling.pgdog.config | object | `{}` | PgDog [general] config overrides. Merged on top of template defaults (healthchecks, timeouts, passthrough_auth, log settings). Any key-value pair added here will be rendered into pgdog.toml. See https://docs.pgdog.dev/configuration/pgdog.toml/general/ |
| pooling.port | int | `5432` | Pooler listen port. Proxy connects to the pooler on this port. |
| pooling.replicas | int | `2` | Number of pooler replicas. |
| ports.cluster | int | `9050` | Cluster peer communication port. |
| ports.metrics | int | `9090` | Prometheus metrics port. |
| ports.readOnly | int | `6142` | Listening port for read-only connections. |
| ports.readWrite | int | `6141` | Listening port for read-write connections. |
| protocol | string | `"PostgreSQL"` | Database protocol. |
| proxyID | string | `""` | ID of this proxy instance. |
| replicas | int | `2` |  |
| resources.cpu | string | `"2"` |  |
| resources.memoryLimit | string | `"2Gi"` |  |
| resources.memoryRequest | string | `"2Gi"` |  |
| rollingUpdate | object | `{"maxSurge":"100%","maxUnavailable":0}` | Rolling update strategy configuration. |
| rollingUpdate.maxSurge | string | `"100%"` | Maximum number of pods that can be created above the desired number of pods during an update. |
| rollingUpdate.maxUnavailable | int | `0` | Maximum number of pods that can be unavailable during an update. |
| service.trafficDistribution | string | `""` | Traffic distribution policy for the service. Set to "PreferClose" to reduce inter-zone traffic. Requires Kubernetes 1.31+. |
| serviceAccountName | string | `""` | The name of the service account to be used by the pod. |
| tls.secretName | string | `""` | Name of a TLS secret (tls.crt/tls.key) to override the built-in self-signed cert. |
| tolerations | object | `{}` | Pod toleration rules. |
| topologySpreadConstraints | list | `[]` | Pod topology spread constraints. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
