# autoscaler

![Version: 0.9.0](https://img.shields.io/badge/Version-0.9.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Wrapper chart for CAST AI Autoscaler profile.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://castai.github.io/helm-charts | castai-agent | 0.145.0 |
| https://castai.github.io/helm-charts | castai-ai-optimizer-proxy | 0.0.115 |
| https://castai.github.io/helm-charts | castai-cluster-controller | 0.90.0 |
| https://castai.github.io/helm-charts | castai-evictor | 0.34.0 |
| https://castai.github.io/helm-charts | castai-kvisor | 1.0.131 |
| https://castai.github.io/helm-charts | castai-live | 0.75.1 |
| https://castai.github.io/helm-charts | castai-pod-mutator | 0.5.0 |
| https://castai.github.io/helm-charts | castai-pod-pinner | 1.10.0 |
| https://castai.github.io/helm-charts | castai-spot-handler | 0.32.0 |
| https://castai.github.io/helm-charts | castai-workload-autoscaler | 0.1.186 |
| https://castai.github.io/helm-charts | castai-workload-autoscaler-exporter | 0.0.107 |
| https://castai.github.io/helm-charts | gpu-metrics-exporter(gpu-metrics-exporter) | 0.1.29 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| castai-agent.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-agent.createNamespace | bool | `false` |  |
| castai-agent.enabled | bool | `true` |  |
| castai-agent.replicaCount | int | `1` |  |
| castai-ai-optimizer-proxy.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-ai-optimizer-proxy.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai-ai-optimizer-proxy.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-ai-optimizer-proxy.enabled | bool | `false` |  |
| castai-cluster-controller.aks.enabled | bool | `false` |  |
| castai-cluster-controller.autoscaling.enabled | bool | `true` |  |
| castai-cluster-controller.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-cluster-controller.enabled | bool | `false` |  |
| castai-cluster-controller.envFrom[0].configMapRef.name | string | `"castai-agent-metadata"` |  |
| castai-evictor.aggressiveMode | bool | `false` |  |
| castai-evictor.enabled | bool | `false` |  |
| castai-evictor.envFrom[0].secretRef.name | string | `"castai-credentials"` |  |
| castai-evictor.envFrom[1].configMapRef.name | string | `"castai-agent-metadata"` |  |
| castai-evictor.overrideEnvFrom | bool | `true` |  |
| castai-evictor.replicaCount | int | `1` |  |
| castai-kvisor.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-kvisor.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai-kvisor.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-kvisor.enabled | bool | `true` |  |
| castai-live.castai-aws-vpc-cni.enabled | bool | `false` |  |
| castai-live.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-live.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-live.controller.replicaCount | int | `0` |  |
| castai-live.daemon.labelNodeSubnet | bool | `true` |  |
| castai-live.enabled | bool | `false` |  |
| castai-pod-mutator.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-pod-mutator.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-pod-mutator.dependencyCheck.enabled | bool | `false` |  |
| castai-pod-mutator.enabled | bool | `false` |  |
| castai-pod-mutator.envFrom[0].configMapRef.name | string | `"castai-agent-metadata"` |  |
| castai-pod-mutator.fullnameOverride | string | `"castai-pod-mutator"` |  |
| castai-pod-pinner.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-pod-pinner.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai-pod-pinner.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-pod-pinner.enabled | bool | `false` |  |
| castai-pod-pinner.replicaCount | int | `0` |  |
| castai-spot-handler.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-spot-handler.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| castai-spot-handler.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| castai-spot-handler.castai.provider | string | `""` |  |
| castai-spot-handler.enabled | bool | `true` |  |
| castai-workload-autoscaler-exporter.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-workload-autoscaler-exporter.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-workload-autoscaler-exporter.enabled | bool | `false` |  |
| castai-workload-autoscaler-exporter.fullnameOverride | string | `"castai-workload-autoscaler-exporter"` |  |
| castai-workload-autoscaler.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| castai-workload-autoscaler.castai.configMapRef | string | `"castai-agent-metadata"` |  |
| castai-workload-autoscaler.enabled | bool | `false` |  |
| castai-workload-autoscaler.fullnameOverride | string | `"castai-workload-autoscaler"` |  |
| gpu-metrics-exporter.castai.apiKeySecretRef | string | `"castai-credentials"` |  |
| gpu-metrics-exporter.castai.clusterIdConfigMapKeyRef.key | string | `"CLUSTER_ID"` |  |
| gpu-metrics-exporter.castai.clusterIdConfigMapKeyRef.name | string | `"castai-agent-metadata"` |  |
| gpu-metrics-exporter.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
