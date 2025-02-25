# castai-hosted-model

CAST AI hosted model deployment chart.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://child-charts/vllm | vllm | 0.0.4 |
| https://otwld.github.io/ollama-helm/ | ollama | 1.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ollama.enabled | bool | `true` |  |
| vllm.enabled | bool | `false` |  |