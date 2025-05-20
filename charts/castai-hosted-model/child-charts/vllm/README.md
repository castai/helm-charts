# vllm

CAST AI hosted model deployment chart for vLLM.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| container.port | int | `8000` |  |
| deployment.labels | string | `nil` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/vllm-openai"` |  |
| image.tag | string | `"v0.8.5"` |  |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":15,"periodSeconds":10}` | Liveness probe configuration |
| livenessProbe.failureThreshold | int | `3` | Number of times after which if a probe fails in a row, Kubernetes considers that the overall check has failed: the container is not alive |
| livenessProbe.httpGet | object | `{"path":"/health"}` | Configuration of the Kubelet http request on the server |
| livenessProbe.httpGet.path | string | `"/health"` | Path to access on the HTTP server |
| livenessProbe.initialDelaySeconds | int | `15` | Number of seconds after the container has started before liveness probe is initiated |
| livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the liveness probe |
| mountImageCache | bool | `false` |  |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health"},"initialDelaySeconds":5,"periodSeconds":5}` | Readiness probe configuration |
| readinessProbe.failureThreshold | int | `3` | Number of times after which if a probe fails in a row, Kubernetes considers that the overall check has failed: the container is not ready |
| readinessProbe.httpGet | object | `{"path":"/health"}` | Configuration of the Kubelet http request on the server |
| readinessProbe.httpGet.path | string | `"/health"` | Path to access on the HTTP server |
| readinessProbe.initialDelaySeconds | int | `5` | Number of seconds after the container has started before readiness probe is initiated |
| readinessProbe.periodSeconds | int | `5` | How often (in seconds) to perform the readiness probe |
| service.port | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| startupProbe.failureThreshold | int | `200` |  |
| startupProbe.httpGet.path | string | `"/health"` |  |
| startupProbe.initialDelaySeconds | int | `20` |  |
| startupProbe.periodSeconds | int | `6` |  |
