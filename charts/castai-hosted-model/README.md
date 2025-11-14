# castai-hosted-model

CAST AI hosted model deployment chart.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/vllm | vllm | 0.0.26 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| placementJob.blacklistedGPUNames | list | `[]` | The names of GPUs that shouldn't be used for this job. |
| placementJob.enabled | bool | `false` | Specifies if a node placement job should be deployed |
| placementJob.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| placementJob.image.repository | string | `"us-docker.pkg.dev/castai-hub/library/busybox"` | The image to use for the job |
| placementJob.image.tag | string | `"1.37.0"` | The image tag |
| placementJob.requiredGPUTotalMemoryMiB | string | `nil` | Total GPU memory MiB (GPU count * GPU memory MiB) of the node that should be provisioned for this job |
| placementJob.resources | object | `{"limits":{"nvidia.com/gpu":1},"requests":{"nvidia.com/gpu":1}}` | Resources for the job |
| podAutoscaler.downFluctuationTolerance | float | `0.2` | which means no scaling down will occur unless the currentMetricValue is less than the targetValue by more than downFluctuationTolerance |
| podAutoscaler.enabled | bool | `false` | Specifies if pod autoscaler should be enabled. It is only relevant for vllm deployments |
| podAutoscaler.maxReplicas | int | `3` | Max number of replicas |
| podAutoscaler.minReplicas | int | `1` | Min number of replicas |
| podAutoscaler.targetDeploymentName | string | `nil` | The name of the vLLM deployment that the pod autoscaler should target |
| podAutoscaler.targetMetric | string | `nil` | The metric to observe for scaling decisions |
| podAutoscaler.targetMetricWindow | string | `"30s"` | Target metric window length |
| podAutoscaler.targetValue | string | `nil` | The threshold value of observed metric to trigger scale up/down decisions |
| podAutoscaler.upFluctuationTolerance | float | `0.1` | which means no scaling up will occur unless the currentMetricValue exceeds the targetValue by more than upFluctuationTolerance |
| vllm.enabled | bool | `true` | Specifies if vLLM model should be deployed |