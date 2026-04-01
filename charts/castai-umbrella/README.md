# castai

Umbrella chart for CAST AI components.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://charts/autoscaler-anywhere | autoscaler-anywhere | * |
| file://charts/autoscaler-openshift | autoscaler-openshift | * |
| file://charts/autoscaler | autoscaler | * |
| file://charts/kent | kent | * |

## Usage

This chart bundles three independent product profiles. Enable exactly one per install.

| Bundle | Enabled by | Target clusters | Components |
|--------|-----------|----------------|-----------|
| **autoscaler** | `tags.<mode>=true` | Managed cloud (EKS, AKS, GKE) | Mode-dependent — see [Autoscaler](#autoscaler) |
| **autoscaler-anywhere** | `tags.autoscaler-anywhere=true` | Non-managed (bare metal, on-prem, edge) | castai-agent, castai-cluster-controller, castai-workload-autoscaler, castai-workload-autoscaler-exporter, castai-evictor, castai-pod-mutator |
| **kent** | `kent.enabled=true` | EKS only | castai-agent, castai-cluster-controller, castai-kentroller, castai-workload-autoscaler, castai-live, castai-pod-mutator, castai-evictor |

---

## Autoscaler

For managed cloud clusters (EKS, AKS, GKE). Select exactly one mode tag — each tag enables a fixed set of components on top of the base observability stack.

### Modes

| Tag | Components | Purpose |
|-----|-----------|---------|
| `readonly` | castai-agent, castai-spot-handler, castai-kvisor, gpu-metrics-exporter | Observability only — no cluster changes |
| `node-autoscaler` | castai-agent, castai-spot-handler, castai-kvisor, gpu-metrics-exporter, castai-cluster-controller, castai-evictor, castai-pod-mutator, castai-pod-pinner, castai-live | Node provisioning and bin-packing |
| `workload-autoscaler` | castai-agent, castai-spot-handler, castai-kvisor, gpu-metrics-exporter, castai-cluster-controller, castai-evictor, castai-pod-mutator, castai-workload-autoscaler, castai-workload-autoscaler-exporter | Vertical pod autoscaling |
| `full` | castai-agent, castai-spot-handler, castai-kvisor, gpu-metrics-exporter, castai-cluster-controller, castai-evictor, castai-pod-mutator, castai-pod-pinner, castai-live, castai-workload-autoscaler, castai-workload-autoscaler-exporter | Node + workload autoscaling |

### Install

```shell
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update

helm upgrade --install castai castai-helm/castai \
  --namespace castai-agent --create-namespace \
  --set global.castai.apiKey=<YOUR_API_KEY> \
  --set global.castai.apiURL=https://api.cast.ai \
  --set global.castai.provider=<eks|aks|gke> \
  --set tags.readonly=true
```

Replace `tags.readonly` with the desired mode tag (`node-autoscaler`, `workload-autoscaler`, or `full`).

#### Using an external secret (Sealed Secrets / ESO / Vault)

If you manage secrets externally, pre-create the `castai-credentials` Secret and pass `apiKeySecretRef` instead of `apiKey`:

```shell
kubectl create namespace castai-agent
kubectl create secret generic castai-credentials \
  --namespace castai-agent \
  --from-literal=API_KEY=<YOUR_API_KEY>

helm upgrade --install castai castai-helm/castai \
  --namespace castai-agent --create-namespace \
  --set global.castai.apiKeySecretRef=castai-credentials \
  --set global.castai.apiURL=https://api.cast.ai \
  --set global.castai.provider=<eks|aks|gke> \
  --set tags.readonly=true
```

The Secret must contain a key named `API_KEY` and be in the same namespace as the release. `apiKey` and `apiKeySecretRef` are mutually exclusive.

### Accepted mode upgrade paths

Upgrades add components; downgrades are not supported because removing active controllers can leave the cluster in an inconsistent state. If you need to move to a lower mode, uninstall the release first and re-install with the target mode.

| From \ To | `readonly` | `node-autoscaler` | `workload-autoscaler` | `full` |
|-----------|:----------:|:-----------------:|:---------------------:|:------:|
| `readonly` | — | ✓ | ✓ | ✓ |
| `node-autoscaler` | ✗ | — | ✗ | ✓ |
| `workload-autoscaler` | ✗ | ✗ | — | ✓ |
| `full` | ✗ | ✗ | ✗ | — |

### Upgrading between modes

Use `--reset-then-reuse-values` to preserve existing configuration when switching modes. Component overrides under `autoscaler.*` are stable across all mode upgrades.

```shell
helm upgrade castai castai-helm/castai \
  --namespace castai-agent \
  --reset-then-reuse-values \
  --set tags.readonly=false \
  --set tags.full=true
```

### Configuring individual components

Pass component-specific values through the `autoscaler.<component>.*` prefix:

```shell
helm upgrade --install castai castai-helm/castai \
  --namespace castai-agent --create-namespace \
  --set global.castai.apiKey=<YOUR_API_KEY> \
  --set global.castai.apiURL=https://api.cast.ai \
  --set global.castai.provider=eks \
  --set tags.full=true \
  --set autoscaler.castai-agent.replicaCount=2 \
  --set autoscaler.castai-evictor.resources.requests.memory=256Mi
```

Or via a values file:

```yaml
global:
  castai:
    apiKey: "<YOUR_API_KEY>"
    apiURL: "https://api.cast.ai"
    provider: eks

tags:
  full: true

autoscaler:
  castai-agent:
    replicaCount: 2
  castai-evictor:
    resources:
      requests:
        memory: 256Mi
```

```shell
helm upgrade --install castai castai-helm/castai \
  --namespace castai-agent --create-namespace \
  -f values.yaml
```

### Disabling a component

Any component can be excluded regardless of the selected mode:

```shell
helm upgrade castai castai-helm/castai \
  --namespace castai-agent \
  --reset-then-reuse-values \
  --set autoscaler.castai-kvisor.enabled=false
```

---

## Autoscaler Anywhere

For non-managed Kubernetes clusters (bare metal, on-prem, edge). Authentication uses a pre-created `castai-credentials` Secret instead of inline API key flags.

### Prerequisites

Create the credentials secret before installing:

```shell
kubectl create namespace castai-agent
kubectl create secret generic castai-credentials \
  --namespace castai-agent \
  --from-literal=TOKEN=<YOUR_API_KEY>
```

### Install

```shell
helm upgrade --install castai castai-helm/castai \
  --namespace castai-agent --create-namespace \
  --set global.castai.apiURL=https://api.cast.ai \
  --set global.castai.apiKey=<YOUR_API_KEY> \
  --set tags.autoscaler-anywhere=true \
  --set autoscaler-anywhere.castai-agent.additionalEnv.ANYWHERE_CLUSTER_NAME=<CLUSTER_NAME>
```

### Configuring individual components

Use the `autoscaler-anywhere.<component>.*` prefix:

```shell
helm upgrade castai castai-helm/castai \
  --namespace castai-agent \
  --reset-then-reuse-values \
  --set autoscaler-anywhere.castai-evictor.aggressiveMode=true
```

---

## Kent

CAST AI Kent profile for EKS clusters. Like Autoscaler Anywhere, authentication uses a pre-created `castai-credentials` Secret.

### Prerequisites

Create the credentials secret before installing:

```shell
kubectl create namespace castai-agent
kubectl create secret generic castai-credentials \
  --namespace castai-agent \
  --from-literal=TOKEN=<YOUR_API_KEY>
```

### Install

```shell
helm upgrade --install castai castai-helm/castai \
  --namespace castai-agent --create-namespace \
  --set global.castai.apiURL=https://api.cast.ai \
  --set kent.enabled=true
```

### Configuring individual components

Use the `kent.<component>.*` prefix:

```shell
helm upgrade castai castai-helm/castai \
  --namespace castai-agent \
  --reset-then-reuse-values \
  --set kent.metrics-server.enabled=true \
  --set kent.castai-live.controller.replicaCount=2
```

---

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaler | object | `{}` |  |
| global.castai.apiKey | string | `""` |  |
| global.castai.apiKeySecretRef | string | `""` |  |
| global.castai.apiURL | string | `"https://api.cast.ai"` |  |
| global.castai.grpcURL | string | `"grpc.cast.ai:443"` |  |
| global.castai.provider | string | `""` |  |
| kent.enabled | bool | `false` |  |
| kent.preflight.enabled | bool | `true` |  |
| tags | object | `{"autoscaler-anywhere":false,"autoscaler-openshift":false,"full":false,"node-autoscaler":false,"readonly":false,"workload-autoscaler":false}` | Profile mode selection (mutually exclusive — pick one). Component overrides are stable across all mode upgrades with --reuse-values:   --set autoscaler.castai-kvisor.enabled=false |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
