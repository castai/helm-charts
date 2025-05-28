# castai-ai-optimizer-proxy

AI Optimizer Proxy deployment chart.

## AiBrix chart

AiBrix does not have an official helm chart. So in order to package the AiBrix deployments, we use `helmify` to
convert AiBrix `kustomize` resources into a helm chart.

In order to update the chart, use the [helmify-aibrix.sh](./helmify-aibrix.sh) script.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/aibrix | aibrix | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnv | object | `{}` |  |
| affinity | object | `{}` |  |
| aibrix.controllerManager.manager.args[0] | string | `"--leader-elect"` |  |
| aibrix.controllerManager.manager.args[1] | string | `"--leader-election-id=castai-aibrix-pod-autoscaler-controller"` |  |
| aibrix.controllerManager.manager.args[2] | string | `"--health-probe-bind-address=:8081"` |  |
| aibrix.controllerManager.manager.args[3] | string | `"--metrics-bind-address=0"` |  |
| aibrix.controllerManager.manager.args[4] | string | `"--controllers=pod-autoscaler-controller"` |  |
| aibrix.controllerManager.manager.args[5] | string | `"--disable-webhook"` |  |
| aibrix.controllerManager.manager.args[6] | string | `"--leader-election-namespace=castai-agent"` |  |
| aibrix.controllerManager.manager.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/aibrix/controller-manager"` |  |
| aibrix.controllerManager.manager.image.tag | string | `"0ca6da25cc3915015fbfd756637a22341d62b50f"` |  |
| aibrix.controllerManager.manager.resources.limits.memory | string | `"64Mi"` |  |
| aibrix.controllerManager.manager.resources.requests.cpu | string | `"10m"` |  |
| aibrix.controllerManager.manager.resources.requests.memory | string | `"64Mi"` |  |
| aibrix.enabled | bool | `true` |  |
| aibrix.fullnameOverride | string | `"castai-aibrix"` |  |
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiURL | string | `"https://api.cast.ai"` |  |
| castai.clusterID | string | `""` |  |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| createNamespace | bool | `false` | By default castai-llms namespace is expected to be created explicitly during onboarding. |
| deploy | bool | `true` |  |
| fullnameOverride | string | `"castai-ai-optimizer-proxy"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/ai-optimizer-proxy"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| routerContainerPort | string | `"10000"` |  |
| routerEndpoint | string | `"http://localhost:10000/v1/chat/completions"` |  |
| routerHealthzEndpoint | string | `"http://localhost:10000/healthz"` |  |
| routerResources | object | `{}` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.port | int | `443` |  |
| service.targetPort | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |