# castai-umbrella

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Umbrella chart for CAST AI components with profile-based installation.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://charts/autoscaler | autoscaler | 0.1.0 |
| file://charts/kent | kent | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler.enabled | bool | `false` |  |
| global.castai.apiKey | string | `""` |  |
| global.castai.apiURL | string | `"https://api.cast.ai"` |  |
| global.castai.grpcURL | string | `"grpc.cast.ai:443"` |  |
| global.castai.provider | string | `""` |  |
| kent.enabled | bool | `false` |  |

