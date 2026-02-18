# vllm

CAST AI hosted model deployment chart for vLLM.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| container.port | int | `8000` |  |
| deployment.labels | string | `nil` |  |
| deployment.strategy | object | `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}` | Deployment strategy configuration |
| deployment.strategy.rollingUpdate | object | `{"maxSurge":"25%","maxUnavailable":"25%"}` | Rolling update configuration (only applies when type is RollingUpdate) |
| deployment.strategy.rollingUpdate.maxSurge | string | `"25%"` | Maximum number of pods that can be created above desired replicas during update |
| deployment.strategy.rollingUpdate.maxUnavailable | string | `"25%"` | Maximum number of pods that can be unavailable during update |
| deployment.strategy.type | string | `"RollingUpdate"` | Deployment strategy type (RollingUpdate or Recreate) |
| dtype | string | `"half"` |  |
| enableAutoToolChoice | bool | `false` |  |
| enableChunkedPrefill | bool | `true` |  |
| enableEager | bool | `false` |  |
| env | list | `[]` | Additional environment variables to set in the vLLM container |
| extraArgs | list | `[]` | Extra arbitrary arguments to pass to vLLM |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/vllm-openai"` |  |
| image.tag | string | `"v0.11.2"` |  |
| kvCacheDtype | string | `"auto"` |  |
| ldLibraryPath | string | `"/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}"` | LD_LIBRARY_PATH environment variable for vLLM container. Set to null or empty string to disable. |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable or disable liveness probe |
| livenessProbe.failureThreshold | int | `3` | Number of times after which if a probe fails in a row, Kubernetes considers that the overall check has failed: the container is not alive |
| livenessProbe.httpGet | object | `{"path":"/health"}` | Configuration of the Kubelet http request on the server |
| livenessProbe.httpGet.path | string | `"/health"` | Path to access on the HTTP server |
| livenessProbe.initialDelaySeconds | int | `15` | Number of seconds after the container has started before liveness probe is initiated |
| livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the liveness probe |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed (must be 1 for liveness probe) |
| livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out |
| loraAdapter.name | string | `nil` | HF Adapter name or path in object storage |
| loraAdapter.registry.createSecret | bool | `true` |  |
| loraAdapter.registry.gcs.credentialsJsonBase64 | string | `nil` |  |
| loraAdapter.registry.hf.token | string | `nil` |  |
| loraAdapter.registry.s3.accessKeyId | string | `nil` |  |
| loraAdapter.registry.s3.endpointUrl | string | `nil` |  |
| loraAdapter.registry.s3.region | string | `nil` |  |
| loraAdapter.registry.s3.secretAccessKey | string | `nil` |  |
| loraAdapter.registry.secretName | string | `nil` |  |
| loraAdapter.sourceRegistry | string | `"hf"` |  |
| maxLoraRank | int | `128` |  |
| maxNumBatchedTokens | int | `10000` |  |
| model.cache.bucket | string | `""` |  |
| model.cache.bucketType | string | `"gcs"` |  |
| model.cache.copyJob.backoffLimit | int | `3` |  |
| model.cache.copyJob.ttlSecondsAfterFinished | int | `0` |  |
| model.cache.createSecret | bool | `true` |  |
| model.cache.enabled | bool | `false` |  |
| model.cache.gcs.credentialsJsonBase64 | string | `nil` |  |
| model.cache.s3.accessKeyId | string | `nil` |  |
| model.cache.s3.endpointUrl | string | `nil` |  |
| model.cache.s3.region | string | `nil` |  |
| model.cache.s3.secretAccessKey | string | `nil` |  |
| model.cache.secretName | string | `nil` |  |
| model.name | string | `nil` | HF Model name or path in object storage |
| model.registry.createSecret | bool | `true` |  |
| model.registry.gcs.credentialsJsonBase64 | string | `nil` |  |
| model.registry.hf.token | string | `nil` |  |
| model.registry.s3.accessKeyId | string | `nil` |  |
| model.registry.s3.endpointUrl | string | `nil` |  |
| model.registry.s3.region | string | `nil` |  |
| model.registry.s3.secretAccessKey | string | `nil` |  |
| model.registry.secretName | string | `nil` |  |
| model.servedName | string | `nil` | Optional override for the served model name. If not set, defaults to model.name |
| model.sourceRegistry | string | `"hf"` |  |
| modelDownloader.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/model-downloader"` |  |
| modelDownloader.image.tag | string | `"v0.0.6"` |  |
| modelDownloader.resources.limits.memory | string | `"500Mi"` |  |
| modelDownloader.resources.requests.cpu | string | `"100m"` |  |
| modelDownloader.resources.requests.memory | string | `"500Mi"` |  |
| podAnnotations | object | `{}` | Additional annotations labels to set for the vLLM pod |
| podLabels | object | `{}` | Additional pod labels to set for the vLLM pod |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable or disable readiness probe |
| readinessProbe.failureThreshold | int | `3` | Number of times after which if a probe fails in a row, Kubernetes considers that the overall check has failed: the container is not ready |
| readinessProbe.httpGet | object | `{"path":"/health"}` | Configuration of the Kubelet http request on the server |
| readinessProbe.httpGet.path | string | `"/health"` | Path to access on the HTTP server |
| readinessProbe.initialDelaySeconds | int | `5` | Number of seconds after the container has started before readiness probe is initiated |
| readinessProbe.periodSeconds | int | `5` | How often (in seconds) to perform the readiness probe |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed |
| readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| service.port | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| startupProbe | object | `{"enabled":true,"failureThreshold":600,"httpGet":{"path":"/health"},"initialDelaySeconds":20,"periodSeconds":6,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable or disable startup probe |
| startupProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed (must be 1 for startup probe) |
| startupProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out |
| task | string | `"generate"` |  |
| useRunAiStreamer | bool | `false` |  |
