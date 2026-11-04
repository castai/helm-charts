# castai-storage-autoscaler Helm Chart

The CAST AI storage autoscaler manages cloud block-storage disks attached to
Kubernetes PVCs. It runs as a controller in the cluster and applies `PVPolicy`
custom resources that scope its behavior to a selected set of PVCs.

## Capabilities

- **Storage capacity** — grow PVCs (and their backing cloud disks) when usage
  crosses a configurable threshold.
- **Performance** — tune provisioned IOPS and throughput on cloud disks based
  on observed workload demand.
- **PVC migration (early access)** — rsync-based migration of a workload from
  one PVC to another (resize across classes/zones, manual data movement).

## Supported clouds

AWS and GCP. The controller auto-detects the cloud provider from the cluster;
see `config.allowUnknownCloudProvider` for local-dev (k3s/kind) clusters.

## Policies

Behavior is driven by `PVPolicy` custom resources (see `templates/pvpolicy-crd.yaml`):

- A default policy is created on startup; additional policies can override it
  by priority and a narrower PVC selector (name, label, or storage class).
- Each policy independently toggles three dimensions: `storage`, `iops`,
  `throughput`.
- Policies can be evaluated in dry-run mode; cooldowns and warmup windows
  guard against thrashing and acting on noisy signals.

## Custom resource definitions

The chart ships two CRDs — `pvpolicies.storage.cast.ai` and
`pvcmigrations.storage.cast.ai` — and installs them by default. When the CRDs
are already present on the cluster (installed out-of-band, e.g. by a platform
operator or a previous release), set `crds.install: false` to skip installing
them. Set `crds.keep: true` to annotate the CRDs with
`helm.sh/resource-policy: keep`, so `helm uninstall` leaves them (and any
PVPolicy/PVCMigration resources) in place. The controller will fail to start
if the CRDs are missing.

## Worker API protection (PVC migration)

The worker HTTP API (TCP 8080) is protected by a per-migration bearer
token: the controller derives one token per migration from the
configured key, injects it into worker pods as `WORKER_AUTH_TOKEN`, and
sends it as the `Authorization` header. `/version` stays
unauthenticated for kubelet readiness probes. Worker pods mount no
ServiceAccount token.

Exactly one of the following must be set when
`migration.workerAuth.enabled=true`; the chart never generates secret
values, so renders are identical across GitOps/Terraform re-renders.

1. `migration.workerAuth.tokenSecretRef` (recommended): an
   operator-managed Secret. Create it before enabling migrations:

   ```
   kubectl -n <release-namespace> create secret generic \
     castai-storage-autoscaler-migration-worker-token \
     --from-literal=worker-token="$(openssl rand -hex 32)"
   ```

2. `migration.workerAuth.token`: inline key for quick setups. It is
   rendered into a chart-managed Secret and must not be committed to
   version control in plain form.

Rotating the key invalidates the derived tokens of in-flight
migrations (worker pods carry the old token in their env): rotate only
while no migration is running, then restart the controller.

Rollout note: if a migration is in flight while the controller
upgrades, a source worker pod recreated by the new controller enforces
rsync auth that a still-old target worker image cannot satisfy — the
migration rolls back (data stays intact) and can be re-run. Upgrade
between migrations to avoid the window.

When `migration.networkPolicy.enabled` is true, the chart ships a
NetworkPolicy that restricts ingress to worker pods in the release
namespace: controller → 8080, kubelet probes (node CIDRs from
`migration.networkPolicy.probeSourceCIDRs`, required) → 8080, and
target-client worker → source worker on 873. Worker pods run in the
migration's namespace, so migrations with PVCs in other namespaces are
protected by the bearer token only — on CNIs that enforce
NetworkPolicy, add equivalent policies for those namespaces or scope
migrations to the release namespace.

Visit https://docs.cast.ai/docs/storage-introduction for detailed documentation.
