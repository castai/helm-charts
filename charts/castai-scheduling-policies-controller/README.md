# castai-scheduling-policies-controller

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.1](https://img.shields.io/badge/AppVersion-v0.0.1-informational?style=flat-square)

CAST AI scheduling policies controller.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| castai.apiKey | string | `""` |  |
| castai.apiKeySecretRef | string | `""` |  |
| castai.apiUrl | string | `"https://api.cast.ai"` |  |
| castai.clusterID | string | `""` |  |
| castai.configMapRef | string | `""` |  |
| dnsConfig | object | `{}` | DNS configuration for the pod ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | DNS Policy Override - Needed when using custom CNI's. Defaults to "ClusterFirstWithHostNet" if hostNetwork is true |
| global | object | `{"commonAnnotations":{},"commonLabels":{}}` | Values to apply for the parent and child chart resources. |
| global.commonAnnotations | object | `{}` | Annotations to add to all resources. |
| global.commonLabels | object | `{}` | Labels to add to all resources. |
| hostNetwork | bool | `false` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/scheduling-policies-controller"` |  |
| image.tag | string | `""` |  |
| podAnnotations | object | `{}` | Annotations added to each pod. |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1005` |  |
| podSecurityContext.runAsGroup | int | `1005` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1005` |  |
| priorityClass.enabled | bool | `false` |  |
| priorityClass.name | string | `"system-cluster-critical"` |  |
| replicas | int | `1` |  |
| resources.limits.memory | string | `"100Mi"` |  |
| resources.requests.cpu | string | `"20m"` |  |
| resources.requests.memory | string | `"100Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations[0].key | string | `"scheduling.cast.ai/spot"` |  |
| tolerations[0].operator | string | `"Exists"` |  |
| webhook.failurePolicy | string | `"Ignore"` |  |
| webhook.reinvocationPolicy | string | `"Never"` |  |
| webhook.url | string | `""` |  |