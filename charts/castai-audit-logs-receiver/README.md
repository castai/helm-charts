# castai-audit-logs-receiver

A Helm chart for CAST AI OpenTelemetry Collector.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| castai.apiKey | string | `""` | Token to be used for authorizing access to the CASTAI API. |
| castai.apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing access to the API. apiKey and apiKeySecretRef are mutually exclusive. The referenced secret must provide the token in .data["CASTAI_API_KEY"]. |
| castai.apiURL | string | `"https://api.cast.ai"` | CASTAI public api url. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| config.exporters.logging.sampling_initial | int | `5` |  |
| config.exporters.logging.sampling_thereafter | int | `200` |  |
| config.exporters.logging.verbosity | string | `"detailed"` |  |
| config.extensions.health_check | object | `{}` |  |
| config.receivers.castai-audit-logs.api.key | string | `"${env:CASTAI_API_KEY}"` | Use CASTAI_API_KEY env variable to provide API Access Key. |
| config.receivers.castai-audit-logs.api.url | string | `"${env:CASTAI_API_URL}"` | Use CASTAI_API_URL env variable to override default API URL (https://api.cast.ai/). |
| config.receivers.castai-audit-logs.filters | object | `{"cluster_id":""}` | Optional configuration for filtering scraped audit logs |
| config.receivers.castai-audit-logs.filters.cluster_id | string | `""` | This optional parameters defines cluster id for which logs should be scraped. |
| config.receivers.castai-audit-logs.page_limit | int | `100` | This parameter defines the max number of records returned from the backend in one page. |
| config.receivers.castai-audit-logs.poll_interval_sec | int | `10` | This parameter defines poll cycle in seconds. |
| config.receivers.castai-audit-logs.storage.filename | string | `"/var/lib/otelcol/file_storage/audit_logs_poll_data.json"` |  |
| config.receivers.castai-audit-logs.storage.type | string | `"persistent"` |  |
| config.service.extensions[0] | string | `"health_check"` |  |
| config.service.pipelines.logs.exporters[0] | string | `"logging"` |  |
| config.service.pipelines.logs.receivers[0] | string | `"castai-audit-logs"` |  |
| config.service.telemetry.logs.level | string | `"debug"` |  |
| configMap.create | bool | `true` | Specifies whether a configMap should be created. |
| containerSecurityContext | object | `{}` |  |
| fullnameOverride | string | `""` | Override the release name used for the full names of resources. |
| hostNetwork | bool | `false` | Host networking requested for this pod. Use the host's network namespace. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/audit-logs-receiver"` |  |
| image.tag | string | `""` |  |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.size | string | `"50M"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` | Annotations to be added to pods. |
| podLabels | object | `{}` | Labels to be added to pods. |
| podSecurityContext | object | `{}` |  |
| resources | object | `{}` |  |
| rollout.rollingUpdate | object | `{}` |  |
| rollout.strategy | string | `"RollingUpdate"` |  |
| statefulset.podManagementPolicy | string | `"Parallel"` |  |
| tolerations | list | `[]` |  |