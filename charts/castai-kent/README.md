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

### Cluster ID
The `castai-agent` registers the cluster and creates the `castai-agent-metadata` ConfigMap
with `CLUSTER_ID` at pod startup. Charts that support runtime ConfigMap references read
from it directly:

| Chart | Reads CLUSTER_ID from castai-agent-metadata? | Mechanism | Needs fix? |
|-------|----------------------------------------------|-----------|------------|
| cluster-controller | Yes | `envFrom` configMapRef | No |
| evictor | Yes | `clusterIdConfigMapKeyRef` | No |
| pod-mutator | Yes | `envFrom` configMapRef (bypasses required check) | No |
| workload-autoscaler | No | reads from CC ConfigMap (no CLUSTER_ID) | Yes — needs `clusterIdConfigMapKeyRef` |
| live | No | only supports `clusterIdSecretKeyRef` | Yes — needs `clusterIdConfigMapKeyRef` |

### API URL
Passed via `global.castai.apiURL`. The Go code fans it out to each sub-chart that
requires it at template time (`cluster-controller.castai.apiURL`,
`kentroller.castai.apiURL`, `live.castai.apiUrl`, `pod-mutator.castai.apiUrl`).

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

For charts that still require clusterID at template time (kentroller, live,
pod-mutator, workload-autoscaler), the Go code passes it via `--set` until
those charts are updated.

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

## Feature flag mapping

How `onboarding.go` Config flags map to umbrella chart values:

| Go Config Field | Umbrella Value |
|----------------|----------------|
| `InstallKubernetesAgent` | `agent.enabled` |
| `InstallClusterController` | `cluster-controller.enabled` |
| `InstallKentroller` | `kentroller.enabled` |
| `InstallWorkloadAutoscaler` | `workload-autoscaler.enabled` |
| `InstallLive` | `live.enabled` |
| `InstallPodMutator` | `pod-mutator.enabled` |
| `InstallEvictor` | `evictor.enabled` |
| `EnableSpotInterruptionPrediction` | `kentroller.castai.spotinterruptionprediction.enabled` |
| `EnableCLM` | `kentroller.castai.clm.enabled` + `live.controller.replicaCount=2` |

## Roadmap: castai-agent-metadata support

To fully eliminate the need for pre-provisioned `CLUSTER_ID`, each sub-chart
needs `clusterIdConfigMapKeyRef` support (like evictor already has). Track
these changes:

- [ ] **castai-kentroller** — add `clusterIdConfigMapKeyRef` (replace static `additionalEnv.CLUSTER_ID`)
- [ ] **castai-workload-autoscaler** — add `clusterIdConfigMapKeyRef`
- [ ] **castai-live** — add `clusterIdConfigMapKeyRef` (currently only supports Secret-based)

Once all charts support it, the install becomes:
```bash
helm upgrade -i castai-kent-onboarding castai-helm/castai-kent-onboarding \
  -n castai-agent --create-namespace \
  --set global.castai.apiKey=$CASTAI_API_TOKEN \
  --set global.castai.apiURL=$CASTAI_API_URL \
  --set global.castai.grpcURL=$CASTAI_GRPC_URL
```
No cluster ID needed — fully runtime-resolved.
