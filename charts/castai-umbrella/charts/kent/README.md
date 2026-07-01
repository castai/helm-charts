# kent

![Version: 0.15.0](https://img.shields.io/badge/Version-0.15.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Wrapper chart for CAST AI Kent profile.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://castai.github.io/helm-charts | castai-agent | 0.158.0 |
| https://castai.github.io/helm-charts | castai-chart-upgrader | 0.2.0 |
| https://castai.github.io/helm-charts | castai-cluster-controller | 0.92.7 |
| https://castai.github.io/helm-charts | castai-kentroller | 0.1.165 |
| https://castai.github.io/helm-charts | castai-kvisor | 1.163.6 |
| https://castai.github.io/helm-charts | castai-live | 0.109.0 |
| https://castai.github.io/helm-charts | castai-pod-mutator | 0.16.0 |
| https://castai.github.io/helm-charts | castai-spot-handler | 0.35.4 |
| https://castai.github.io/helm-charts | castai-workload-autoscaler | 1.3.2 |
| https://castai.github.io/helm-charts | castai-workload-autoscaler-exporter | 1.3.2 |
| https://kubernetes-sigs.github.io/metrics-server/ | metrics-server | 3.13.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| castai-agent.apiKeySecretRef | string | `""` |  |
| castai-agent.clusterVPA.enabled | bool | `true` |  |
| castai-agent.clusterVPA.resources | object | `{}` |  |
| castai-agent.containerSecurityContext | object | `{}` |  |
| castai-agent.createNamespace | bool | `false` |  |
| castai-agent.enabled | bool | `true` |  |
| castai-agent.metadataStore.createConfigMap | bool | `true` |  |
| castai-agent.monitor.resources | object | `{}` |  |
| castai-agent.provider | string | `"eks"` |  |
| castai-agent.replicaCount | int | `1` |  |
| castai-agent.resources | object | `{}` |  |
| castai-chart-upgrader.chart.name | string | `"castai"` |  |
| castai-chart-upgrader.chart.repository | string | `"https://castai.github.io/helm-charts"` |  |
| castai-chart-upgrader.enabled | bool | `false` |  |
| castai-cluster-controller.autoscaling.enabled | bool | `false` |  |
| castai-cluster-controller.castai.apiKeySecretRef | string | `""` |  |
| castai-cluster-controller.containerSecurityContext | object | `{}` |  |
| castai-cluster-controller.enabled | bool | `true` |  |
| castai-cluster-controller.envFrom[0].configMapRef.name | string | `"castai-agent-metadata"` |  |
| castai-cluster-controller.monitor.resources | object | `{}` |  |
| castai-cluster-controller.resources | object | `{}` |  |
| castai-kentroller.castai.apiKeySecretRef | string | `""` |  |
| castai-kentroller.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-kentroller.castai.organizationIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-kentroller.enabled | bool | `true` |  |
| castai-kvisor.agent.containerSecurityContext | object | `{}` |  |
| castai-kvisor.agent.enabled | bool | `false` |  |
| castai-kvisor.agent.reliabilityMetrics.obi.containerSecurityContext | object | `{}` |  |
| castai-kvisor.castai.apiKeySecretRef | string | `""` |  |
| castai-kvisor.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai-kvisor.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-kvisor.controller.containerSecurityContext | object | `{}` |  |
| castai-kvisor.controller.enabled | bool | `true` |  |
| castai-kvisor.controller.extraArgs.cluster-proxy-enabled | string | `"true"` |  |
| castai-kvisor.controller.extraArgs.log-level | string | `"info"` |  |
| castai-kvisor.enabled | bool | `true` |  |
| castai-live.castai.apiKeySecretRef | string | `""` |  |
| castai-live.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-live.controller.replicaCount | int | `0` |  |
| castai-live.daemon.labelNodeSubnet | bool | `true` |  |
| castai-live.enabled | bool | `true` |  |
| castai-pod-mutator.castai.apiKeySecretRef | string | `""` |  |
| castai-pod-mutator.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-pod-mutator.containerSecurityContext | object | `{}` |  |
| castai-pod-mutator.dependencyCheck.enabled | bool | `false` |  |
| castai-pod-mutator.enabled | bool | `true` |  |
| castai-pod-mutator.envFrom[0].configMapRef.name | string | `"castai-agent-metadata"` |  |
| castai-spot-handler.apiKeySecretRef | string | `""` |  |
| castai-spot-handler.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai-spot-handler.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-spot-handler.castai.provider | string | `"eks"` |  |
| castai-spot-handler.enabled | bool | `true` |  |
| castai-workload-autoscaler-exporter.castai.apiKeySecretRef | string | `""` |  |
| castai-workload-autoscaler-exporter.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-workload-autoscaler-exporter.containerSecurityContext | object | `{}` |  |
| castai-workload-autoscaler-exporter.enabled | bool | `true` |  |
| castai-workload-autoscaler-exporter.prometheus.containerSecurityContext | object | `{}` |  |
| castai-workload-autoscaler.castai.apiKeySecretRef | string | `""` |  |
| castai-workload-autoscaler.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-workload-autoscaler.containerSecurityContext | object | `{}` |  |
| castai-workload-autoscaler.enabled | bool | `true` |  |
| metrics-server.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
