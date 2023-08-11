# castai-hibernate

CAST AI hibernate CronJobs used to pause and resume Kubernetes cluster on a defined schedule.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentNamespace | string | `"castai-agent"` |  |
| apiKey | string | `""` | API token with Full Access permissions and encode base64 |
| backoffLimit | int | `0` |  |
| cloud | string | `""` | Set CronJobs "Cloud" env variable to [EKS|GKE|AKS] |
| clusterRoleBindingAdminName | string | `"hibernate-admin"` |  |
| clusterRoleBindingName | string | `"hibernate"` |  |
| clusterRoleName | string | `"hibernate"` |  |
| concurrencyPolicy | string | `"Forbid"` |  |
| configMapName | string | `"castai-cluster-controller"` |  |
| hibernateNode | string | `""` | Set the HIBERNATE_NODE environment variable to override the default node sizing selections. Make sure the size selected is appropriate for your cloud. |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"castai/hibernate"` |  |
| image.tag | string | `""` | Tag is set using Chart.yaml appVersion field. |
| namespace | string | `"castai-agent"` | By default namespace is expected to be created by castai-agent. |
| namespacesToKeep | string | `""` | Set the NAMESPACES_TO_KEEP environment variable to override, "opa,istio"" |
| pauseCronJobName | string | `"hibernate-pause"` | hibernate-pause cronjob schedule. |
| pauseCronSchedule | string | `"0 22 * * 1-5"` | update hibernate-pause schedule according to business needs. |
| podSecurityContext.fsGroup | int | `1003` |  |
| podSecurityContext.runAsGroup | int | `1003` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1003` |  |
| protectRemovalDisabled | string | `"false"` | This looks for the autoscaling.cast.ai/removal-disabled="true" label on a node and if it exists excludes it from being cordoned and deleted. |
| restartPolicy | string | `"OnFailure"` |  |
| resumeCronJobName | string | `"hibernate-resume"` | hibernate-resume cronjob schedule. |
| resumeCronSchedule | string | `"0 7 * * 1-5"` | update hibernate-resume schedule according to business needs. |
| roleBindingName | string | `"hibernate"` |  |
| roleName | string | `"hibernate"` |  |
| secretName | string | `"castai-hibernate"` |  |
| serviceAccountName | string | `"hibernate"` |  |