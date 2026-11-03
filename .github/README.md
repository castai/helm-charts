# Releasing charts

How a chart ends up in this repository's Helm index and, signed, on GHCR. For CAST AI engineers
who build charts; customers only need [Verifying a chart](#verifying-a-chart).

## One publisher

Every chart release is made by one workflow, [`publish-chart.yml`](workflows/publish-chart.yml).
It never builds anything. Given a chart name, a version and a `source`, it:

1. pulls the chart from the source registry and checks that it is signed by one of the identities
   that [`chart-signers.yaml`](chart-signers.yaml) trusts for that source;
2. copies it, signature included, to `ghcr.io/castai/helm-charts/<chart>:<version>` and verifies
   it again there (a chart built in this repository is pushed there directly and verified in place);
3. creates the GitHub release `<chart>-<version>` with the `.tgz` and updates `index.yaml`, which
   is what `helm repo add castai-helm https://castai.github.io/helm-charts` serves;
4. optionally (`sync_source`) unpacks the chart into `charts/<chart>` on `main`, for charts whose
   source lives elsewhere but whose files are kept here as a copy.

A chart that is not signed, or signed by someone the source does not trust, is released nowhere.
The release is created with an octo-sts token rather than the workflow's own `GITHUB_TOKEN`, because
only a release made by an app or a user starts the workflows that react to it (the umbrella bump).

`publish-chart.yml` is started by the pipeline that built the chart, which then waits for it, so
every build shows one outcome. It can also be started by hand from the Actions tab.

## Where charts come from

| Built in | Pushed and signed to | Who starts `publish-chart.yml` | `source` |
|---|---|---|---|
| GitLab: kubecast, clm, pv-monitor | the internal chart registry, signed by the project's CI identity | [castai/images](https://github.com/castai/images) `publish.yml`, which also publishes the images | `gitlab` |
| this repository: the charts listed under `sources.helm-charts.charts` in `chart-signers.yaml`, the umbrella among them | `ghcr.io/castai/helm-charts/<chart>`, signed by [`release.yaml`](workflows/release.yaml) | `release.yaml`, on every push to `main`, for each listed chart whose version has no release yet | `helm-charts` |
| another GitHub repository: kontext, castware-operator, gcp-disk-compatibility-webhook, ai-enabler | `ghcr.io/castai/<repo>/helm-charts/<chart>`, signed by that repository's release workflow | the [`remote-release`](actions/remote-release/README.md) action, from the repository's own workflow | the repository name |

Every other directory under `charts/` is a copy of a chart built elsewhere. `release.yaml` never
builds or releases those, whatever their version says.

**The umbrella** (`charts/castai-umbrella`, released as `castai`) is a chart of the second kind.
When a child chart is released, `update-umbrella-on-child-release.yaml` bumps the dependency on
`main`, and that push makes `release.yaml` release the new umbrella version. `release-umbrella-rc`,
`e2e-umbrella` and `release-cnab` react to that release.

## The files

| File | What it decides |
|---|---|
| [`chart-signers.yaml`](chart-signers.yaml) | Trust. Per source: the registry charts are pulled from, the OIDC issuer and the certificate identities allowed to sign them. For `github`, also the list of charts built here. |
| [`chainguard/*.sts.yaml`](chainguard) | Who may act on this repository through [octo-sts](https://github.com/octo-sts/app). `images-publish` and `<repo>-publish` let a builder start `publish-chart.yml` (`actions: write`). `chart-publish` lets `publish-chart.yml` on `main` create releases and push the index (`contents: write`). `umbrella-bump` lets the two umbrella workflows push the bump commit to `main` as octo-sts[bot], which is what starts `release.yaml` for the new umbrella version (a push by the job's own token would not). octo-sts reads them from the default branch only. |
| [`workflows/publish-chart.yml`](workflows/publish-chart.yml) | The release itself, see above. Runs on `main` only. |
| [`workflows/release.yaml`](workflows/release.yaml) | Builds, pushes and signs the charts of this repository, then starts `publish-chart.yml` for each. Also the fallback umbrella bump. |
| [`actions/remote-release`](actions/remote-release/README.md) | The composite action other repositories call. Bumps `Chart.yaml`, pushes and signs into the caller's GHCR namespace, starts `publish-chart.yml`, waits, commits the bump back. |

Changing the trust file or a policy changes who can publish a chart to customers, so these files
go through review like code.

## Adding a chart

**Built in this repository.** Add its name to `sources.helm-charts.charts` in `chart-signers.yaml`.
From then on, every merged version bump releases it. Dependencies from Helm repositories must be
reachable with the repositories `release.yaml` adds.

**Built in another GitHub repository.** In this repository, one pull request:

- a source in `chart-signers.yaml`: registry `ghcr.io/castai/<repo>/helm-charts`, the GitHub
  Actions issuer and the identity of the release workflow, usually
  `^https://github\.com/castai/<repo>/\.github/workflows/<file>@refs/tags/`;
- the same name in the `source` options of `publish-chart.yml`;
- `chainguard/<repo>-publish.sts.yaml`, copied from an existing one with the repository name and id.

In the other repository, the release workflow calls `remote-release`; the
[action's README](actions/remote-release/README.md) has the example and the inputs. The first
release of each chart stops once: GitHub creates the package private and has no API to change it.
Make `ghcr.io/castai/<repo>/helm-charts/<chart>` public, re-run the failed job, done.

**Built in GitLab.** Use the chart release template of kubecast (or the equivalent job in clm and
pv-monitor); it pushes to the internal registry and signs. A new GitLab project needs its CI
identity added to `sources.gitlab.identities`.

## When something fails

Every step is safe to re-run: a chart already pushed and signed is reused, an existing release is
skipped, the index push retries. Re-run the failed job, not the whole workflow.

| Symptom | Meaning |
|---|---|
| `… is not public. Make the package public once …` | First release from a GitHub repository, see above. |
| `no signature …` or `verification failed` for a GitLab chart | The pipeline did not sign, or signed with an identity not in `chart-signers.yaml`. The chart is not released. |
| `… has no release, but <chart> is not in sources.helm-charts.charts` (warning) | A version bump in a copied chart. Release it from where it is built. |
| the chart is released but the umbrella did not move | Look at `update-umbrella-on-child-release.yaml` for that release; `release.yaml` on the next push to `main` is the fallback. |
| `publish-chart run … failed` in the builder's log | Open the linked run; the builder only reports it. |

## Verifying a chart

Every signed chart on GHCR carries a keyless cosign signature. Who signed it is fixed by its
source in `chart-signers.yaml`:

```sh
# a chart built in GitLab (most charts)
cosign verify \
  --certificate-oidc-issuer https://gitlab.com \
  --certificate-identity-regexp '^https://gitlab\.com/castai/kubecast//\.gitlab-ci\.yml@' \
  ghcr.io/castai/helm-charts/castai-agent:<version>

# a chart built in this repository, the umbrella included
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/castai/helm-charts/\.github/workflows/release\.yaml@refs/heads/main$' \
  ghcr.io/castai/helm-charts/castai:<version>

helm pull oci://ghcr.io/castai/helm-charts/<chart> --version <version>
```

The `.tgz` attached to the GitHub release is byte for byte the chart that was signed.
