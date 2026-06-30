# castai-dbo

Umbrella chart for CAST AI Database Optimizer components.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CAST AI |  | <https://cast.ai> |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://castai.github.io/helm-charts | db-agent(castai-db-agent) | 0.22.1 |
| https://castai.github.io/helm-charts | db-optimizer(castai-db-optimizer) | 0.80.1 |
| https://castai.github.io/helm-charts | db-proxy(castai-db-proxy) | 0.1.3 |

## Usage

```shell
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update

helm upgrade --install castai-dbo castai-helm/castai-dbo \
  --namespace castai-agent --create-namespace \
  --set db-optimizer.apiKey=<API_KEY> \
  --set db-optimizer.organizationID=<ORG_ID> \
  --set db-optimizer.cacheGroupID=<CACHE_GROUP_ID> \
  --set db-optimizer.protocol=PostgreSQL \
  --set db-agent.apiKey=<API_KEY> \
  --set db-agent.organizationID=<ORG_ID> \
  --set db-agent.cacheGroupID=<CACHE_GROUP_ID>
```

### Configuring individual components

Pass component-specific values through the `<component>.*` prefix:

```shell
helm upgrade --install castai-dbo castai-helm/castai-dbo \
  --namespace castai-agent --create-namespace \
  -f values.yaml
```

### Disabling a component

Any sub-chart can be excluded:

```shell
helm upgrade castai-dbo castai-helm/castai-dbo \
  --namespace castai-agent \
  --reset-then-reuse-values \
  --set db-proxy.enabled=false
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| db-agent.enabled | bool | `true` |  |
| db-optimizer.enabled | bool | `true` |  |
| db-proxy.enabled | bool | `true` |  |
| global | object | `{"organizationID":""}` | Global values forwarded to all sub-charts. |
| global.organizationID | string | `""` | Organization ID shared by all DBO components. |
