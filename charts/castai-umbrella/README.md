# castai-umbrella

`castai-umbrella` is a parent chart that installs one of two CAST AI modes:

- `autoscaler` (aka regular castai)
- `kent`

It exists to give a single entrypoint and keep profile-specific defaults inside wrapper subcharts.
Modes defaults are defined in wrapper charts:
    - `helm-charts-public/charts/castai-umbrella/charts/kent/values.yaml`
    - `helm-charts-public/charts/castai-umbrella/charts/autoscaler/values.yaml`

## How to use

Both modes are disabled by default.
Enable exactly one mode at install time.

Install Kent:

```bash
helm install castai helm-charts-public/charts/castai-umbrella \
  --set kent.enabled=true \
  --set global.castai.apiKey=<API_KEY>
```

Install Autoscaler:

```bash
helm install castai helm-charts-public/charts/castai-umbrella \
  --set autoscaler.enabled=true \
  --set global.castai.apiKey=<API_KEY> \
  --set autoscaler.agent.provider=<eks|aks|gke|kops|anywhere>
```

## What each mode contains (TODO: clarify with autoscaler)

| Component                  | Kent     | Autoscaler |
|----------------------------|----------|------------|
| castai-agent               | Yes      | Yes        |
| castai-cluster-controller  | Yes      | Yes        |
| castai-kentroller          | Yes      | No         |
| castai-workload-autoscaler | Yes      | Yes        |
| castai-live                | Yes      | Yes        |
| castai-pod-mutator         | Yes      | Yes        |
| castai-evictor             | Yes      | Yes        |
| castai-spot-handler        | No       | Yes        |
| metrics-server             | Optional | Optional   |

## Notes

- Shared settings like `global.castai.apiKey` are configured in umbrella values.
- `global.castai.apiKey` is required when `kent` or `autoscaler` is enabled.
- Kent provider defaults to `eks` in wrapper values.
- `autoscaler.agent.provider` is required for Autoscaler installs.
- Autoscaler defaults are placeholders and should be tuned before production use.
