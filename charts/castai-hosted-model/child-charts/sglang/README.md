# sglang

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.1](https://img.shields.io/badge/AppVersion-v0.0.1-informational?style=flat-square)

CAST AI hosted model deployment chart for SGLang.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| container.port | int | `8000` |  |
| deployment.labels | string | `nil` |  |
| deployment.strategy | object | `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}` | Deployment strategy configuration |
| deployment.strategy.type | string | `"RollingUpdate"` | Deployment strategy type (RollingUpdate or Recreate) |
| enabled | bool | `false` | Specifies if the SGLang model should be deployed. Controlled by the parent chart condition. |
| env | list | `[]` | Additional environment variables to set in the SGLang container |
| extraArgs | list | `[]` | Extra arbitrary arguments passed verbatim to `sglang.launch_server`. Use this for everything beyond the hardcoded --model-path/--served-model-name/--host/--port/--tp-size flags (e.g. --context-length, --dtype, --quantization, --mem-fraction-static, --reasoning-parser, --tool-call-parser). |
| extraVolumeMounts | list | `[]` | Extra volumeMounts appended to the SGLang container (verbatim mount list). |
| extraVolumes | list | `[]` | Extra volumes appended to the pod (verbatim volume list). |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/sglang"` |  |
| image.tag | string | `"v0.5.13"` |  |
| initContainers | list | `[]` | Init containers to run before the SGLang server (verbatim pod-spec list). Used e.g. to pre-compile GPU JIT kernels once (single-writer) into a shared cache so the TP ranks don't race to compile them at first forward. |
| ldLibraryPath | string | `""` |  |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration |
| model.hfToken | string | `nil` | HuggingFace token used to pull gated/private models. |
| model.name | string | `nil` | HF model name or repo id (e.g. "meta-llama/Llama-3.1-8B-Instruct"). Only the HuggingFace source is supported. |
| model.servedName | string | `nil` | Optional override for the served model name. If not set, defaults to model.name. |
| nodeSelector | object | `{}` |  |
| persistence | object | `{"hostPath":{"enabled":false,"path":"","type":"DirectoryOrCreate"}}` | Model weight storage. When hostPath is enabled, weights are saved to a node-local directory (e.g. /mnt/models/<model>) so they survive pod restarts on the same node. When disabled, an emptyDir is used and weights are re-downloaded on every pod start. |
| podAnnotations | object | `{}` | Additional pod annotations to set for the SGLang pod |
| podLabels | object | `{}` | Additional pod labels to set for the SGLang pod |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| router | object | `{"affinity":{},"balanceAbsThreshold":64,"balanceRelThreshold":1.5,"cacheThreshold":0.3,"enabled":false,"evictionIntervalSecs":120,"extraArgs":[],"image":{"repository":"","tag":""},"livenessProbe":{"enabled":true,"failureThreshold":5,"httpGet":{"path":"/health"},"initialDelaySeconds":10,"periodSeconds":20,"timeoutSeconds":3},"metrics":{"enabled":true,"port":29000},"nodeSelector":{},"pdb":{"enabled":false,"maxUnavailable":null,"minAvailable":1},"podAnnotations":{},"podAntiAffinity":{"enabled":true,"topologyKey":"kubernetes.io/hostname","type":"required"},"podLabels":{},"policy":"cache_aware","port":8000,"production":{"cbFailureThreshold":3,"cbTimeoutDurationSecs":15,"healthCheckIntervalSecs":15,"maxConcurrentRequests":512,"queueTimeoutSecs":60,"retryMaxRetries":3},"readinessProbe":{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":10,"timeoutSeconds":3},"replicaCount":2,"resources":{"limits":{"memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}},"serviceDiscovery":{"enabled":true,"extraSelector":{},"namespace":""},"startupProbe":{"enabled":true,"failureThreshold":60,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":5,"timeoutSeconds":3},"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"},"syncWaves":{"enabled":true,"rbac":"-2","router":"-1","service":"0"},"tolerations":[],"workerGrpcPort":20000,"workerProtocol":"http"}` | SGLang Model Gateway (cache-aware router) placed IN FRONT of the worker pods. When enabled: the model Service targets the ROUTER pod instead of the workers; the workers become a bare Deployment (no Service) and the router discovers them dynamically by label via Kubernetes service-discovery. Clients keep hitting the same Service name/port — only what's behind it changes. The router is OpenAI-compatible (same /v1/* endpoints, streaming forwarded). |
| router.balanceAbsThreshold | int | `64` | Absolute load-imbalance threshold (requests) before rebalancing away from cache locality. |
| router.balanceRelThreshold | float | `1.5` | Relative load-imbalance ratio before rebalancing. |
| router.cacheThreshold | float | `0.3` | Cache-aware tuning (defaults match SGLang). Min prefix-match ratio to prefer cache locality. |
| router.enabled | bool | `false` | Deploy the cache-aware router in front of the workers. |
| router.evictionIntervalSecs | int | `120` | Router's own radix-tree eviction cadence (seconds). |
| router.extraArgs | list | `[]` | Extra args passed verbatim to sglang_router.launch_router. |
| router.image.repository | string | `""` | Router image. Defaults to the same SGLang image (it ships sglang_router). |
| router.metrics | object | `{"enabled":true,"port":29000}` | Prometheus metrics. The router serves smg_* metrics at /metrics on metricsPort (separate from the API port). Mirrors how workers expose metrics (on-pod, scraped directly). |
| router.podAntiAffinity | object | `{"enabled":true,"topologyKey":"kubernetes.io/hostname","type":"required"}` | Spread router replicas across nodes. Only takes effect when replicaCount > 1 (a single router has nothing to separate from). Keeps the replicas off the same node so one node failure or drain cannot take out all router replicas at once. Merged with any explicit router.affinity below; the cluster's CAST admission webhook still injects nodeAffinity. |
| router.policy | string | `"cache_aware"` | Routing policy. cache_aware keeps cross-worker prefix affinity (pairs with the workers' HiRadixCache/HiCache). Other options: round_robin, random, power_of_two, bucket. |
| router.port | int | `8000` | Router HTTP port. Should equal service.port so the Service contract is unchanged. |
| router.production | object | `{"cbFailureThreshold":3,"cbTimeoutDurationSecs":15,"healthCheckIntervalSecs":15,"maxConcurrentRequests":512,"queueTimeoutSecs":60,"retryMaxRetries":3}` | Production resilience flags (sgl_model_gateway production recommendations). |
| router.replicaCount | int | `2` | Default 2 replicas for HA behind the model Service. NOTE: router replicas do NOT share their cache-aware radix tree (no cross-replica sync), so >1 replica trades ~10-20% cache-hit rate for availability. Set to 1 for maximum cache locality (single coherent tree). |
| router.serviceDiscovery | object | `{"enabled":true,"extraSelector":{},"namespace":""}` | Kubernetes service discovery: the router watches pods matching this selector (defaults to the worker selector labels of THIS instance). Requires pod get/list/watch RBAC. |
| router.serviceDiscovery.extraSelector | object | `{}` | Extra label selector to add on top of the worker selector. Map of key: value. |
| router.serviceDiscovery.namespace | string | `""` | Namespace to watch. Defaults to the release namespace if empty. |
| router.syncWaves | object | `{"enabled":true,"rbac":"-2","router":"-1","service":"0"}` | Zero-downtime cutover ordering (ArgoCD sync-waves). When enabled, the router's RBAC/ServiceAccount and Deployment are applied in EARLIER waves than the model Service, so Argo waits for the router pod to reach Ready health before the Service selector flips from the workers to the router. This prevents the brief empty- endpoint window that an atomic selector switch would otherwise cause. The workers keep serving the whole time (their Deployment is untouched by enabling the router). Only emitted when router.enabled=true; a router-less model's Service is unchanged. Requires an ArgoCD-managed rollout with automated sync. |
| router.workerGrpcPort | int | `20000` | Worker gRPC port (only used when workerProtocol=grpc). Must match the worker's gRPC port. |
| router.workerProtocol | string | `"http"` | Protocol the router uses to reach the WORKERS. Clients always talk HTTP/OpenAI to the router regardless. "http" = current path (workers run sglang.launch_server, no boot change). "grpc" = the Rust fast-path (router tokenizes, streams token-ids to SRT gRPC workers) — this REQUIRES the workers to be launched as SRT gRPC workers (--grpc-mode, gRPC port) and HiCache re-validated under that mode. Not a free flag flip on the worker side. |
| service.annotations | object | `{}` | Extra annotations for the model Service. Merged with the router sync-wave annotation (see router.syncWaves) when the router is enabled. |
| service.port | int | `8000` |  |
| service.publicName | string | `""` |  |
| service.type | string | `"ClusterIP"` |  |
| shm.sizeLimit | string | `"10Gi"` | Size limit of the shared-memory (/dev/shm) emptyDir used for tensor-parallel inference. Increase for large models / high tensor-parallel degrees; decrease to save node RAM. |
| startupProbe | object | `{"enabled":true,"failureThreshold":600,"httpGet":{"path":"/health"},"initialDelaySeconds":20,"periodSeconds":6,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| tensorParallelSize | string | `nil` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
