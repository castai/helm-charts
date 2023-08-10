# castai-hibernate

Hibernate is a set of CronJobs that can be used to pause and resume Kubernetes cluster on a defined schedule

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentNamespace | string | `"castai-agent"` |  |
| apiKey | string | `""` | API token with Full Access permissions and encode base64 |
| backoffLimit | int | `0` |  |
| cloud | string | `""` | Cloud env variable to [EKS|GKE|AKS] |
| clusterRoleBindingAdminName | string | `"hibernate-admin"` |  |
| clusterRoleBindingName | string | ``"hibernate"` |  |
| clusterRoleName | string | `"hibernate"` |  |
| concurrencyPolicy | bool | `Forbid` |  |
| configMapName | string | `"castai-cluster-controller"` |  |
| hibernateNode | string | `""`  | Set the HIBERNATE_NODE environment variable to override the default node sizing selections. Make sure the size selected is appropriate for your cloud. |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"castai/hibernate"` |  |
| image.tag | string | `""` | Tag is set using Chart.yaml appVersion field. |
| namespace | string | `"castai-agent"` |  |
| namespacesToKeep | string | `""` | Set the NAMESPACES_TO_KEEP environment variable to override, "opa,istio"" |
| pauseCronJobName | string | `"hibernate-pause"` | |
| pauseCronSchedule | string | `"0 22 * * 1-5"` | Schedule to pause cluster. |
| podSecurityContext.fsGroup | int | `1003` |  |
| podSecurityContext.runAsGroup | int | `{}` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1003` |  |
| protectRemovalDisabled | string | `"false"` |  |
| resumeCronJobName | string | `"hibernate-resume"` | |
| resumeCronSchedule | string | `"0 7 * * 1-5"` | Schedule to resume cluster. |
| roleName| string | `"hibernate"` |  |
| roleBindingName | string | `"hibernate"` |  |
| secretName | string | `castai-hibernate` |  |
| serviceAccountName | string | `hibernate` |  |
| restartPolicy | string | `OnFailure` |  |
