# castai-kent-onboarding

Umbrella chart that consolidates CAST AI kent onboarding components into a single Helm release.

## Included dependencies

| Component | Alias | Purpose |
|-----------|-------|---------|
| `castai-agent` | `agent` | Cluster registration and ID bootstrapping |
| `castai-cluster-controller` | `cluster-controller` | Cluster lifecycle management (credential hub) |
| `castai-kentroller` | `kentroller` | Karpenter enterprise node management |
| `castai-workload-autoscaler` | `workload-autoscaler` | Workload right-sizing |
| `castai-live` | `live` | Cost Limit Management (CLM) |
| `castai-pod-mutator` | `pod-mutator` | Pod mutation webhooks |
| `castai-evictor` | `evictor` | Node draining and eviction |
| `metrics-server` | `metrics-server` | Resource metrics (prerequisite for workload-autoscaler) |

All dependencies are optional and controlled by `<alias>.enabled` values.
All components enabled by default except `agent` and `metrics-server`.

## How credentials and cluster ID flow

```
                              castai-credentials Secret
global.castai.apiKey ──────► (created by umbrella chart) ──► all sub-charts (apiKeySecretRef)

                              castai-agent-metadata ConfigMap
castai-agent pod ──────────► (created at runtime by agent) ──► CLUSTER_ID
                                       │
                    ┌──────────────────┼────────────────────┐
                    ▼                  ▼                    ▼
             cluster-controller    evictor             pod-mutator
             (envFrom)        (clusterIdConfigMapKeyRef)  (envFrom)

                              castai-cluster-controller ConfigMap
cluster-controller ────────► (API_URL only, no CLUSTER_ID) ──► workload-autoscaler, pod-mutator, evictor
```

### API Key
The umbrella chart creates a shared **Secret** (`castai-credentials`) from `global.castai.apiKey`.
All sub-charts reference it via `apiKeySecretRef`.

## Usage

```bash
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update castai-helm

helm upgrade -i castai-kent-onboarding castai-helm/castai-kent-onboarding \
  -n castai-agent --create-namespace \
  --set global.castai.apiKey=$CASTAI_API_TOKEN \
  --set global.castai.apiURL=$CASTAI_API_URL \
  --set global.castai.grpcURL=$CASTAI_GRPC_URL
```

`CLUSTER_ID` is resolved at runtime from the `castai-agent-metadata` ConfigMap
(no `--set` needed for charts that support it).


## Versioning and lockfile workflow

- This umbrella chart is versioned independently from sub-charts (SemVer).
- Sub-chart versions are resolved via `Chart.lock` for reproducible deployments.
- Bump the umbrella chart `version` in `Chart.yaml` when:
  - You change the dependency list or version constraints.
  - You change default values or templates.
- After changing dependencies, run:
  ```bash
  helm dependency update
  ```
  Then commit the updated `Chart.lock` and `charts/*.tgz` artifacts.
