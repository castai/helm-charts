# sglang

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.1](https://img.shields.io/badge/AppVersion-v0.0.1-informational?style=flat-square)

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
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/sglang"` |  |
| image.tag | string | `"v0.5.13"` |  |
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
| router | object | `{"affinity":{},"balanceAbsThreshold":64,"balanceRelThreshold":1.5,"cacheThreshold":0.3,"enabled":false,"evictionIntervalSecs":120,"extraArgs":[],"image":{"repository":"","tag":""},"livenessProbe":{"enabled":true,"failureThreshold":5,"httpGet":{"path":"/health"},"initialDelaySeconds":10,"periodSeconds":20,"timeoutSeconds":3},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"policy":"cache_aware","port":8000,"readinessProbe":{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":10,"timeoutSeconds":3},"replicaCount":1,"resources":{"limits":{"memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}},"serviceDiscovery":{"enabled":true,"extraSelector":{},"namespace":""},"startupProbe":{"enabled":true,"failureThreshold":60,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":5,"timeoutSeconds":3},"tolerations":[]}` | SGLang Model Gateway (cache-aware router) placed IN FRONT of the worker pods. When enabled: the model Service targets the ROUTER pod instead of the workers; the workers become a bare Deployment (no Service) and the router discovers them dynamically by label via Kubernetes service-discovery. Clients keep hitting the same Service name/port — only what's behind it changes. The router is OpenAI-compatible (same /v1/* endpoints, streaming forwarded). |
| router.balanceAbsThreshold | int | `64` | Absolute load-imbalance threshold (requests) before rebalancing away from cache locality. |
| router.balanceRelThreshold | float | `1.5` | Relative load-imbalance ratio before rebalancing. |
| router.cacheThreshold | float | `0.3` | Cache-aware tuning (defaults match SGLang). Min prefix-match ratio to prefer cache locality. |
| router.enabled | bool | `false` | Deploy the cache-aware router in front of the workers. |
| router.evictionIntervalSecs | int | `120` | Router's own radix-tree eviction cadence (seconds). |
| router.extraArgs | list | `[]` | Extra args passed verbatim to sglang_router.launch_router. |
| router.image.repository | string | `""` | Router image. Defaults to the same SGLang image (it ships sglang_router). |
| router.policy | string | `"cache_aware"` | Routing policy. cache_aware keeps cross-worker prefix affinity (pairs with the workers' HiRadixCache/HiCache). Other options: round_robin, random, power_of_two, bucket. |
| router.port | int | `8000` | Router HTTP port. Should equal service.port so the Service contract is unchanged. |
| router.serviceDiscovery | object | `{"enabled":true,"extraSelector":{},"namespace":""}` | Kubernetes service discovery: the router watches pods matching this selector (defaults to the worker selector labels of THIS instance). Requires pod get/list/watch RBAC. |
| router.serviceDiscovery.extraSelector | object | `{}` | Extra label selector to add on top of the worker selector. Map of key: value. |
| router.serviceDiscovery.namespace | string | `""` | Namespace to watch. Defaults to the release namespace if empty. |
| service.port | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| shm.sizeLimit | string | `"10Gi"` | Size limit of the shared-memory (/dev/shm) emptyDir used for tensor-parallel inference. Increase for large models / high tensor-parallel degrees; decrease to save node RAM. |
| startupProbe | object | `{"enabled":true,"failureThreshold":600,"httpGet":{"path":"/health"},"initialDelaySeconds":20,"periodSeconds":6,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| tensorParallelSize | string | `nil` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
