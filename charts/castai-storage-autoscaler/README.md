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

Visit https://docs.cast.ai/docs/storage-introduction for detailed documentation.

## Custom resource definitions

The chart ships two CRDs — `pvpolicies.storage.cast.ai` and
`pvcmigrations.storage.cast.ai` — and installs them by default. When the CRDs
are already present on the cluster (installed out-of-band, e.g. by a platform
operator or a previous release), set `crds.install: false` to skip installing
them. Set `crds.keep: true` to annotate the CRDs with
`helm.sh/resource-policy: keep`, so `helm uninstall` leaves them (and any
PVPolicy/PVCMigration resources) in place. The controller will fail to start
if the CRDs are missing.