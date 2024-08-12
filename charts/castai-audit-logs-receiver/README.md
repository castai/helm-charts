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
| config.extensions.health_check.endpoint | string | `"0.0.0.0:13133"` |  |
| config.receivers.castai_audit_logs.api.key | string | `"${env:CASTAI_API_KEY}"` |  |
| config.receivers.castai_audit_logs.api.url | string | `"${env:CASTAI_API_URL}"` |  |
| config.receivers.castai_audit_logs.filters.cluster_id | string | `""` |  |
| config.receivers.castai_audit_logs.page_limit | int | `100` |  |
| config.receivers.castai_audit_logs.poll_interval_sec | int | `10` |  |
| config.receivers.castai_audit_logs.storage.filename | string | `"/var/lib/otelcol/file_storage/audit_logs_poll_data.json"` |  |
| config.receivers.castai_audit_logs.storage.type | string | `"persistent"` |  |
| config.service.extensions[0] | string | `"health_check"` |  |
| config.service.pipelines.logs.exporters[0] | string | `"logging"` |  |
| config.service.pipelines.logs.receivers[0] | string | `"castai_audit_logs"` |  |
| config.service.telemetry.logs.level | string | `"debug"` |  |
| configMap.create | bool | `true` | Specifies whether a configMap should be created. |
| containerSecurityContext | object | `{}` |  |
| fullnameOverride | string | `""` | Override the release name used for the full names of resources. |
| hostNetwork | bool | `false` | Host networking requested for this pod. Use the host's network namespace. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"us-docker.pkg.dev/castai-hub/library/audit-logs-receiver"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` | Specify image pull secrets |
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