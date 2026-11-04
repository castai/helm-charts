# remote-release

Releases a chart that lives in another CAST AI repository through `castai/helm-charts`, signed:

1. bumps `Chart.yaml` (patch bump + `appVersion` = tag, or version = tag with `chart-version-from-tag`),
2. packages the chart and pushes it to **your repository's GHCR namespace**,
   `ghcr.io/castai/<repo>/helm-charts/<chart>:<version>`, with the job's `GITHUB_TOKEN`,
3. signs it keyless with cosign (the certificate names your workflow),
4. starts `publish-chart.yml` in `castai/helm-charts` and waits for it. That workflow verifies the
   signature against `.github/chart-signers.yaml`, copies the chart to
   `ghcr.io/castai/helm-charts/<chart>`, creates the GitHub release and updates `index.yaml`,
5. commits the `Chart.yaml` bump back to your `main` (unless `commit-chart-changes: "false"`).

## What your repository needs

- The chart job's permissions:
  ```yaml
  permissions:
    contents: write   # only for the Chart.yaml commit back; read is enough otherwise
    id-token: write   # keyless signature and the token for castai/helm-charts
    packages: write   # push to ghcr.io/castai/<repo>/helm-charts/<chart>
  ```
- No secret. The old `helm-charts-repo-token` (cicdcast PAT) and the `chart-releaser-*` inputs are gone.
- In `castai/helm-charts` (one PR, reviewed by cast-platform), once per repository:
  - a source in `.github/chart-signers.yaml`: `registry: ghcr.io/castai/<repo>/helm-charts`, the GitHub
    Actions issuer, and the identity of your release workflow(s), e.g.
    `^https://github\.com/castai/<repo>/\.github/workflows/release\.yaml@refs/tags/`;
  - that source in the `source` options of `.github/workflows/publish-chart.yml`;
  - `.github/chainguard/<repo>-publish.sts.yaml`: lets your release workflow start `publish-chart.yml`
    (`actions: write`). The `source` input of this action must equal the entry name.
- **Once per chart, by hand**: GitHub creates `ghcr.io/castai/<repo>/helm-charts/<chart>` as a private
  package (your repository is private) and has no API to change that. The first run stops after the
  push with the instruction; make the package public (Packages → the package → Package settings →
  Change visibility), then re-run the job. The pushed, signed chart is reused.
  - Alternative for sources that must stay private: set `private: true` on the source in
    `.github/chart-signers.yaml`, grant the `castai/helm-charts` repository read access to the
    package (Package settings → Manage Actions access), and skip the visibility flip. publish-chart
    pulls the chart with its own GITHUB_TOKEN; the anonymous-pull check in this action is skipped
    and downgraded to a warning in publish-chart's job summary.

## Example

```yaml
jobs:
  chart:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
      packages: write
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0
      - uses: castai/helm-charts/.github/actions/remote-release@<sha>
        with:
          chart-path: ${{ github.workspace }}/charts/my-chart
          release-tag: ${{ needs.prepare.outputs.release-tag }}
```

## Inputs

| Input | Default | Meaning |
|---|---|---|
| `chart-path` | required | chart directory |
| `release-tag` | tag of `GITHUB_REF` | `appVersion` (auto-bump mode) or the chart version |
| `chart-version-from-tag` | `false` | `true`: chart version = tag without `v` |
| `source` | repository name | entry in `chart-signers.yaml` |
| `chart-registry` | `ghcr.io/castai/<repo>/helm-charts` | must equal the source's registry |
| `release-notes` | description + source commit | release body |
| `sync-chart` | `false` | also unpack the released chart into `charts/<chart>` on helm-charts `main` |
| `helm-upgrade-summary` | `helm upgrade -i …` | job summary line |
| `commit-chart-changes` | `true` | commit the `Chart.yaml` bump back |
| `source-repo-token` | job token | token for that commit |
| `git-author-name` / `git-author-email` | the actor | author of that commit |
| `github-token` | `github.token` | GHCR and this repository's API |

Outputs: `chart`, `version`, `digest`, `publish-run-url`.

## Verifying a released chart

```sh
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '<identity from chart-signers.yaml>' \
  ghcr.io/castai/helm-charts/<chart>:<version>
```
