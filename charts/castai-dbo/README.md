# castai-dbo

Umbrella chart for CAST AI Database Optimizer components.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CAST AI |  | <https://cast.ai> |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://castai.github.io/helm-charts | db-agent(castai-db-agent) | 0.22.0 |
| https://castai.github.io/helm-charts | db-optimizer(castai-db-optimizer) | 0.80.1 |
| https://castai.github.io/helm-charts | db-proxy(castai-db-proxy) | 0.2.1 |

## Usage

```shell
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update

helm upgrade --install castai-dbo castai-helm/castai-dbo \
  --namespace castai-agent --create-namespace \
  -f values.yaml
```

See below for the required values for each component.

> **Note:** `db-proxy` and `db-optimizer` are mutually exclusive — enable only one of them.

### Example: db-optimizer + db-agent

```yaml
db-optimizer:
  enabled: true
  apiKey: "<API_KEY>"
  organizationID: "<ORG_ID>"
  cacheGroupID: "<CACHE_GROUP_ID>"
  protocol: "PostgreSQL"
  endpoints:
    - name: "primary"
      hostname: "<DB_HOST>"
      port: 5433
      targetPort: 5432
      servicePort: 5433

db-agent:
  enabled: true
  apiKey: "<API_KEY>"
  organizationID: "<ORG_ID>"
  cacheGroupID: "<CACHE_GROUP_ID>"
  database:
    host: "<DB_HOST>"
    username: "<DB_USER>"
    password: "<DB_PASSWORD>"
```

### Example: db-proxy + db-agent

```yaml
db-proxy:
  enabled: true
  apiKey: "<API_KEY>"
  organizationID: "<ORG_ID>"
  proxyID: "<PROXY_ID>"
  endpoints:
    - address: "<DB_HOST>:<DB_PORT>"
      readonly: false

db-agent:
  enabled: true
  apiKey: "<API_KEY>"
  organizationID: "<ORG_ID>"
  cacheGroupID: "<CACHE_GROUP_ID>"
  database:
    host: "<DB_HOST>"
    username: "<DB_USER>"
    password: "<DB_PASSWORD>"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| db-agent.enabled | bool | `false` |  |
| db-optimizer.enabled | bool | `false` |  |
| db-proxy.enabled | bool | `false` |  |
