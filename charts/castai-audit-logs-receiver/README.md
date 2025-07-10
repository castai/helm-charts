# castai-audit-logs-receiver

A Helm chart for CAST AI OpenTelemetry Collector.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| castai.apiKey | string | `""` | Token to be used for authorizing access to the CASTAI API. |
| castai.apiKeySecretRef | string | `""` | Name of secret with Token to be used for authorizing access to the API. apiKey and apiKeySecretRef are mutually exclusive. The referenced secret must provide the token in .data["CASTAI_API_KEY"]. |
| castai.apiURL | string | `"https://api.cast.ai"` | CASTAI public api url. |
| castai.clusterID | string | `""` | Cluster id to be used for filtering audit logs. |
| castai.clusterIdSecretKeyRef.key | string | `"CASTAI_CLUSTER_ID"` |  |
| castai.clusterIdSecretKeyRef.name | string | `""` |  |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| config.exporters.debug.sampling_initial | int | `5` |  |
| config.exporters.debug.sampling_thereafter | int | `200` |  |
| config.exporters.debug.verbosity | string | `"detailed"` |  |
| config.extensions.health_check.endpoint | string | `"0.0.0.0:13133"` |  |
| config.receivers.castai_audit_logs.api.key | string | `"${env:CASTAI_API_KEY}"` |  |
| config.receivers.castai_audit_logs.api.url | string | `"${env:CASTAI_API_URL}"` |  |
| config.receivers.castai_audit_logs.filters.cluster_id | string | `"${env:CASTAI_CLUSTER_ID}"` |  |
| config.receivers.castai_audit_logs.page_limit | int | `100` |  |
| config.receivers.castai_audit_logs.poll_interval_sec | int | `30` |  |
| config.receivers.castai_audit_logs.storage.filename | string | `"/var/lib/otelcol/file_storage/audit_logs_poll_data.json"` |  |
| config.receivers.castai_audit_logs.storage.type | string | `"persistent"` |  |
| config.service.extensions[0] | string | `"health_check"` |  |
| config.service.pipelines.logs.exporters[0] | string | `"debug"` |  |
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
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set, the default serviceAccount will be used. |
| statefulset.podManagementPolicy | string | `"Parallel"` |  |
| tolerations | list | `[]` |  |