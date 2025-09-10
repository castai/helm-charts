# vllm

CAST AI hosted model deployment chart for vLLM.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| container.port | int | `8000` |  |
| deployment.labels | string | `nil` |  |
| dtype | string | `"half"` |  |
| enableAutoToolChoice | bool | `false` |  |
| enableChunkedPrefill | bool | `true` |  |
| env | list | `[]` | Additional environment variables to set in the vLLM container |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/vllm-openai"` |  |
| image.tag | string | `"v0.9.2"` |  |
| kvCacheDtype | string | `"auto"` |  |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration |
| livenessProbe.enabled | bool | `true` | Enable or disable liveness probe |
| livenessProbe.failureThreshold | int | `3` | Number of times after which if a probe fails in a row, Kubernetes considers that the overall check has failed: the container is not alive |
| livenessProbe.httpGet | object | `{"path":"/health"}` | Configuration of the Kubelet http request on the server |
| livenessProbe.httpGet.path | string | `"/health"` | Path to access on the HTTP server |
| livenessProbe.initialDelaySeconds | int | `15` | Number of seconds after the container has started before liveness probe is initiated |
| livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the liveness probe |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed (must be 1 for liveness probe) |
| livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out |
| loraAdapter.name | string | `nil` | HF Model name or path in object storage |
| loraAdapter.sourceRegistry | string | `"hf"` |  |
| maxLoraRank | int | `128` |  |
| maxNumBatchedTokens | int | `10000` |  |
| model.name | string | `nil` | HF Model name or path in object storage |
| model.sourceRegistry | string | `"hf"` |  |
| modelDownloader.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/model-downloader"` |  |
| modelDownloader.image.tag | string | `"v0.0.1"` |  |
| modelDownloader.resources.limits.memory | string | `"500Mi"` |  |
| modelDownloader.resources.requests.cpu | string | `"100m"` |  |
| modelDownloader.resources.requests.memory | string | `"500Mi"` |  |
| modelDownloader.s3ProxyResources.limits.memory | string | `"1Gi"` |  |
| modelDownloader.s3ProxyResources.requests.cpu | string | `"100m"` |  |
| modelDownloader.s3ProxyResources.requests.memory | string | `"1Gi"` |  |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration |
| readinessProbe.enabled | bool | `true` | Enable or disable readiness probe |
| readinessProbe.failureThreshold | int | `3` | Number of times after which if a probe fails in a row, Kubernetes considers that the overall check has failed: the container is not ready |
| readinessProbe.httpGet | object | `{"path":"/health"}` | Configuration of the Kubelet http request on the server |
| readinessProbe.httpGet.path | string | `"/health"` | Path to access on the HTTP server |
| readinessProbe.initialDelaySeconds | int | `5` | Number of seconds after the container has started before readiness probe is initiated |
| readinessProbe.periodSeconds | int | `5` | How often (in seconds) to perform the readiness probe |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed |
| readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out |
| registries.createSecret | bool | `true` |  |
| registries.gcs.credentialsJsonBase64 | string | `nil` |  |
| registries.hf.token | string | `nil` |  |
| registries.secretName | string | `nil` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| service.port | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| startupProbe | object | `{"enabled":true,"failureThreshold":200,"httpGet":{"path":"/health"},"initialDelaySeconds":20,"periodSeconds":6,"successThreshold":1,"timeoutSeconds":1}` | Startup probe configuration |
| startupProbe.enabled | bool | `true` | Enable or disable startup probe |
| startupProbe.failureThreshold | int | `200` |  |
| startupProbe.httpGet.path | string | `"/health"` |  |
| startupProbe.initialDelaySeconds | int | `20` |  |
| startupProbe.periodSeconds | int | `6` |  |
| startupProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed (must be 1 for startup probe) |
| startupProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out |
| task | string | `"generate"` |  |
| useRunAiStreamer | bool | `false` |  |
