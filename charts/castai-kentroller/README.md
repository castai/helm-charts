# castai-kentroller

Deploys the CAST AI kentroller — the in-cluster controller for KENT (Karpenter Enterprise by CAST AI), responsible for automated Kubernetes cluster management.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://dependencies/crds | castai-kentroller-crds | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["castai-kentroller"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Pod affinity/anti-affinity rules. podAntiAffinity is used when enableTopologySpreadConstraints is false. |
| azure | object | `{"subscriptionID":"","workloadIdentityClientID":""}` | Azure-specific configuration. Required when provider is "azure". |
| azure.subscriptionID | string | `""` | Azure subscription ID used for Azure inventory lookups. |
| azure.workloadIdentityClientID | string | `""` | Client ID of the Azure AD Workload Identity to federate. Wires the ServiceAccount annotation and pod label AKS's workload identity webhook requires. |
| castai | object | `{"apiKey":"","apiKeySecretRef":"","apiURL":"https://api.cast.ai","audit":{"createNamespace":true,"enabled":true,"namespace":"castai-audit"},"clm":{"enabled":false},"clusterIdConfigMapKeyRef":{"key":"CLUSTER_ID","name":""},"commitmentBudgets":{"drainMode":"off","enabled":true,"nodePoolFilterMode":"opt-out"},"continuousRebalancing":{"aggressiveModeConfig":{},"cycleIntervalSeconds":60,"deleteEmptyCycleIntervalSeconds":60,"drainOnlyCycleIntervalSeconds":60,"enabled":false,"evictionConfig":[],"fullModeCycleIntervalSeconds":1800,"minNodeAgeSeconds":300,"mode":"full","savingsThresholdPercent":15,"savingsThresholdPercentage":15},"grpcURL":"grpc.prod-master.cast.ai:443","organizationIdConfigMapKeyRef":{"key":"ORGANIZATION_ID","name":""},"otelMetrics":{"enabled":true},"rebalance":{"disruptGuard":true,"enabled":true,"namespaceLabeling":true,"preferenceWeightedPacking":true},"spotInterruptionPrediction":{"enabled":true}}` | CAST AI API configuration |
| castai.apiKey | string | `""` | Token for authorizing agent access to the CAST AI API |
| castai.apiKeySecretRef | string | `""` | Name of secret with token for authorizing agent access to the API. apiKey and apiKeySecretRef are mutually exclusive. The referenced secret must provide the token in .data["API_KEY"]. |
| castai.apiURL | string | `"https://api.cast.ai"` | CAST AI public API URL |
| castai.clm | object | `{"enabled":false}` | Enable CLM node labeling feature |
| castai.clusterIdConfigMapKeyRef | object | `{"key":"CLUSTER_ID","name":""}` | Name and key of ConfigMap with cluster ID. The referenced ConfigMap must provide the cluster ID in .data[<<.Values.castai.clusterIdConfigMapKeyRef.key>>]. |
| castai.commitmentBudgets | object | `{"drainMode":"off","enabled":true,"nodePoolFilterMode":"opt-out"}` | CommitmentBudgets controller configuration. |
| castai.commitmentBudgets.drainMode | string | `"off"` | Controls over-limit drain enforcement. - off (default): no drain claims are created; over-limit pools emit warning events only. - safe: over-limit budget NodePools get auto-executing RebalancePlanClaims   that respect PDBs and NodePool disruption budgets. - aggressive: drain claims ignore blocking PDBs and zero NodePool   disruption budgets and evict aggressively until back within limits. |
| castai.commitmentBudgets.enabled | bool | `true` | Enable the CommitmentBudgets controller. When disabled, kentroller will not reconcile CommitmentBudget CRDs into Karpenter NodePools. |
| castai.commitmentBudgets.nodePoolFilterMode | string | `"opt-out"` | Controls which customer NodePools are considered for shadow NodePool creation. Annotate a NodePool with kentroller.cast.ai/commitment-nodepool-clone: "include" or "exclude" to control inclusion. - opt-out (default): all NodePools are included unless annotated "exclude". - opt-in: only NodePools annotated "include" are included. |
| castai.continuousRebalancing | object | `{"aggressiveModeConfig":{},"cycleIntervalSeconds":60,"deleteEmptyCycleIntervalSeconds":60,"drainOnlyCycleIntervalSeconds":60,"enabled":false,"evictionConfig":[],"fullModeCycleIntervalSeconds":1800,"minNodeAgeSeconds":300,"mode":"full","savingsThresholdPercent":15,"savingsThresholdPercentage":15}` | Continuous rebalancing feature configuration |
| castai.continuousRebalancing.aggressiveModeConfig | object | `{}` | Bypass safety checks globally during rebalancing. When set, these flags apply to all nodes and pods in every rebalancing cycle. Use evictionConfig for per-pod/per-node granularity instead.  aggressiveModeConfig:   ignoreLocalPersistentVolumes: false   ignoreProblemRemovalDisabledPods: false   ignoreProblemJobPods: false   ignoreProblemPodsWithoutController: false   ignoreInstanceCriteria: false   ignoreBlockingPDB: false   ignoreBlockingPDBTimeout: 10m   aggressiveEviction: false   drainTimeout: 10m |
| castai.continuousRebalancing.cycleIntervalSeconds | int | `60` | Interval in seconds between rebalancing cycles. Mutually exclusive with the mode-specific interval fields (fullModeCycleIntervalSeconds, drainOnlyCycleIntervalSeconds, deleteEmptyCycleIntervalSeconds). When set to a non-default value and no mode-specific intervals are configured, this value is used for all modes. If any mode-specific interval is set, this field is ignored for mode scheduling. |
| castai.continuousRebalancing.deleteEmptyCycleIntervalSeconds | int | `60` | Interval between delete-empty rebalancing cycles (default 1m). When set, cycleIntervalSeconds is ignored for mode scheduling. |
| castai.continuousRebalancing.drainOnlyCycleIntervalSeconds | int | `60` | Interval between drain-only rebalancing cycles (default 1m). When set, cycleIntervalSeconds is ignored for mode scheduling. |
| castai.continuousRebalancing.enabled | bool | `false` | Whether continuous rebalancing is enabled |
| castai.continuousRebalancing.evictionConfig | list | `[]` | Fine-grained control over which pods and nodes may be touched during rebalancing. Each entry targets either pods or nodes (not both).  removalDisabled — pods/nodes matching this selector are never evicted or drained, regardless of any other settings.   evictionConfig:     - nodeSelectorTerm:         labelSelector:           matchLabels:             dedicated: gpu       settings:         removalDisabled:           enabled: true  aggressive — allows evicting single-replica pods and pods protected by a PodDisruptionBudget.   evictionConfig:     - podSelector:         labelSelector:           matchLabels:             cast.ai/eviction-policy: aggressive       settings:         aggressive:           enabled: true  disposable — pods matching this selector pass all eviction checks as long as they can be rescheduled elsewhere (or are inherently non-reschedulable, like Jobs); PDDs and replica guards are ignored.   evictionConfig:     - podSelector:         kind: Job         namespace: batch       settings:         disposable:           enabled: true |
| castai.continuousRebalancing.fullModeCycleIntervalSeconds | int | `1800` | Interval between full continuous rebalancing cycles (expensive, default 30m). When set, cycleIntervalSeconds is ignored for mode scheduling. |
| castai.continuousRebalancing.minNodeAgeSeconds | int | `300` | Minimum time in seconds a node must exist before it is considered for replacement. Avoids churning nodes that just started up. |
| castai.continuousRebalancing.mode | string | `"full"` | Mode of continuous rebalancing. Available values: - delete-empty: Only delete empty nodes. - drain-only: Bin-pack nodes by draining into existing spare capacity. - full: Replace inefficient nodes with better-fit ones. Maximum savings, but most churn. |
| castai.continuousRebalancing.savingsThresholdPercent | int | `15` | Minimum cluster-scoped cost savings percentage for performing a rebalance action. The value is compared against projected savings as a percentage of total cluster cost, not the cost of replaced nodes. Relevant only for modes that can replace nodes (full mode). |
| castai.continuousRebalancing.savingsThresholdPercentage | int | `15` | [OBSOLETE] Use savingsThresholdPercent instead. Kept for backward compatibility. If set, it is used as a fallback when savingsThresholdPercent is not set. |
| castai.organizationIdConfigMapKeyRef | object | `{"key":"ORGANIZATION_ID","name":""}` | Name and key of ConfigMap with organization ID. The referenced ConfigMap must provide the organization ID in .data[<<.Values.castai.organizationIdConfigMapKeyRef.key>>]. |
| castai.otelMetrics | object | `{"enabled":true}` | OpenTelemetry metrics export configuration |
| castai.otelMetrics.enabled | bool | `true` | Enable OTel metrics export via the same gRPC endpoint as Kent. In connected mode only — standalone always disables outbound OTLP export; the local metrics endpoint is controlled separately by metrics.enabled. |
| castai.rebalance | object | `{"disruptGuard":true,"enabled":true,"namespaceLabeling":true,"preferenceWeightedPacking":true}` | Enable rebalance feature |
| castai.rebalance.disruptGuard | bool | `true` | Enable the disrupt guard for manual/scheduled rebalance plans: while a plan executes, cluster nodes are annotated with karpenter.sh/do-not-disrupt=true so the Karpenter consolidator does not compete for the same free capacity; the annotation is reverted on plan completion. Static setting (env-based, unlike preferenceWeightedPacking) — changing it requires a kentroller pod restart. Default: true. |
| castai.rebalance.namespaceLabeling | bool | `true` | Enable applying the rebalancing.cast.ai/active label to namespaces during rebalancing. The label drives the TSC mutating webhook, but it also causes Cilium to recompute security identities for every pod in those namespaces. Disable this if you do not use hard hostname/zone TopologySpreadConstraints and want to avoid transient identity churn. Default: true. |
| castai.rebalance.preferenceWeightedPacking | bool | `true` | Enable preference-weighted packing in the rebalance plan generator. Scores candidate nodes by cost + reliability + preference penalties (PodAffinity, TopologySpread, VolumeZone) instead of pure cheapest-fit. Hot-reloadable via kubectl-edit on the dynamic config ConfigMap. Default: true. |
| castai.spotInterruptionPrediction | object | `{"enabled":true}` | Enable CAST AI Spot prediction in connected mode. Standalone mode always disables this CAST ML dependency while retaining local observed-interruption handling. |
| crds | object | `{"enabled":true}` | CRDs subchart configuration |
| crds.enabled | bool | `true` | Install CRDs as a dependency subchart |
| deploymentAnnotations | object | `{"workloads.cast.ai/configuration":"horizontal:\n   optimization: off\nvertical:\n  optimization: on\n  cpu:\n    target: p75\n    lookBackPeriod: 168h\n    min: 1000m\n  memory:\n    target: p90\n    lookBackPeriod: 168h\n"}` | Annotations applied to the Deployment resource itself. The workloads.cast.ai/configuration annotation enables CAST AI Vertical Pod Autoscaler (VPA) and must be on the Deployment, not the pod template. with CPU min 1000m, P75 CPU target, P90 memory target, and the longest supported look-back period (168h). |
| deploymentMode | string | `"connected"` | Runtime connectivity contract. One of: connected, standalone. Standalone mode has no required runtime connection to the CAST Control Plane and injects inert sentinel values for the binary's required CAST configuration fields. |
| dynamicConfig | object | `{"annotations":{"argocd.argoproj.io/compare-options":"IgnoreExtraneous"}}` | Settings for the dynamic config ConfigMap managed at runtime by kentroller. |
| dynamicConfig.annotations | object | `{"argocd.argoproj.io/compare-options":"IgnoreExtraneous"}` | Annotations applied to the dynamic config ConfigMap. |
| enableTopologySpreadConstraints | bool | `false` | Use topologySpreadConstraints instead of podAntiAffinity. |
| envFrom | list | `[]` | Additional environment sources (ConfigMaps/Secrets) for runtime config. |
| fullnameOverride | string | `"castai-kentroller"` |  |
| global.castai.apiKeySecretRef | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.registry | string | `""` |  |
| global.tolerations | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/castai/images/kentroller"` |  |
| image.tag | string | `""` |  |
| metrics | object | `{"enabled":true,"port":8443,"service":{"enabled":true}}` | Metrics endpoint configuration |
| metrics.enabled | bool | `true` | Enable metrics endpoint on :8443 |
| metrics.port | int | `8443` | Port for the metrics endpoint |
| metrics.service | object | `{"enabled":true}` | Create a Service for metrics |
| nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node selector for pod scheduling. kentroller must run on Linux nodes only — it manages Windows node rebalancing but cannot run on Windows itself (no Windows build of the binary). |
| podAnnotations | object | `{}` | Annotations applied to the pod template. |
| provider | string | `"aws"` | Cloud provider for this cluster, selecting the cloud-provider implementation used by the rebalancer. One of: aws, azure, gcp. |
| replicaCount | int | `2` |  |
| resources.limits.memory | string | `"2Gi"` |  |
| resources.requests.cpu | int | `1` |  |
| resources.requests.memory | string | `"2Gi"` |  |
| securityContext | object | `{"fsGroup":1003,"runAsGroup":1003,"runAsNonRoot":true,"runAsUser":1003}` | Pod security context. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| tolerations | list | `[]` | Tolerations for pod scheduling. |
| topologySpreadConstraints | list | `[{"labelSelector":{"matchLabels":{"app.kubernetes.io/name":"castai-kentroller"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}]` | Topology spread constraints for pod scheduling. Used when enableTopologySpreadConstraints is true. |
| webhook | object | `{"certPath":"/tmp/k8s-webhook-server/serving-certs","certsSecretName":"","enabled":true,"scaleDown":{"enabled":false,"mode":"opt-in"}}` | Pod TopologySpreadConstraints mutating webhook configuration.  TLS material is provisioned and rotated in-process by open-policy-agent cert-controller (see setupCertRotator in cmd/main.go), so cert-manager and a pre-supplied caBundle are not required. The chart only needs to render the MutatingWebhookConfiguration, the Service, an empty Secret rendezvous point, and the RBAC the rotator uses to patch them. |
| webhook.certPath | string | `"/tmp/k8s-webhook-server/serving-certs"` | Filesystem directory inside the pod where the cert-rotator writes the serving cert/key/ca files. Mounted as an emptyDir. |
| webhook.certsSecretName | string | `""` | Override for the Secret that cert-controller uses as its rotation rendezvous point. Defaults to "<fullname>-webhook-certs" if empty. |
| webhook.enabled | bool | `true` | Whether to render the MutatingWebhookConfiguration, webhook Service, certs Secret, and pass --webhook-cert-path to kentroller. |
| webhook.scaleDown | object | `{"enabled":false,"mode":"opt-in"}` | Deployments/scale downscaling webhook. Intercepts HPA-driven scale-downs to preserve Topology Spread Constraint skew. |
| webhook.scaleDown.enabled | bool | `false` | Install the MutatingWebhookConfiguration and register the handler. |
| webhook.scaleDown.mode | string | `"opt-in"` | namespaceSelector strategy. "opt-in" selects only namespaces labeled tsc-scaledown.cast.ai/enabled=true; "opt-out" selects all namespaces unless labeled tsc-scaledown.cast.ai/disabled=true. |