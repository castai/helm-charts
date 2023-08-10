# castai-hibernate

CAST AI hibernate CronJobs used to pause and resume Kubernetes cluster on a defined schedule.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentNamespace | string | `"castai-agent"` |  |
| apiKey | string | `""` |  |
| backoffLimit | int | `0` |  |
| cloud | string | `""` |  |
| clusterRoleBindingAdminName | string | `"hibernate-admin"` |  |
| clusterRoleBindingName | string | `"hibernate"` |  |
| clusterRoleName | string | `"hibernate"` |  |
| concurrencyPolicy | string | `"Forbid"` |  |
| configMapName | string | `"castai-cluster-controller"` |  |
| hibernateNode | string | `""` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"castai/hibernate"` |  |
| image.tag | string | `""` |  |
| namespace | string | `"castai-agent"` |  |
| namespacesToKeep | string | `""` |  |
| pauseCronJobName | string | `"hibernate-pause"` |  |
| pauseCronSchedule | string | `"0 22 * * 1-5"` |  |
| podSecurityContext.fsGroup | int | `1003` |  |
| podSecurityContext.runAsGroup | int | `1003` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1003` |  |
| protectRemovalDisabled | string | `"false"` |  |
| restartPolicy | string | `"OnFailure"` |  |
| resumeCronJobName | string | `"hibernate-resume"` |  |
| resumeCronSchedule | string | `"0 7 * * 1-5"` |  |
| roleBindingName | string | `"hibernate"` |  |
| roleName | string | `"hibernate"` |  |
| secretName | string | `"castai-hibernate"` |  |
| serviceAccountName | string | `"hibernate"` |  |