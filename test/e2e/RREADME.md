# castai-umbrella e2e Tests

End-to-end tests for the `castai-umbrella` Helm chart. Each test context spins up its own
[Kind](https://kind.sigs.k8s.io/) cluster, installs the chart in a specific mode, verifies
all pods and releases are healthy, and tears everything down afterwards.

## Test modes covered

| Context | What it tests |
|---|---|
| **kent mode** | `kent.enabled=true` – installs castai-agent + castai-kentroller |
| **autoscaler mode** | `autoscaler.enabled=true` – installs castai-agent + cluster-controller + evictor |
| **clean uninstall** | Installs autoscaler mode then uninstalls; verifies no leftover resources |

## Prerequisites

| Tool | Install |
|---|---|
| `kind` | https://kind.sigs.k8s.io/docs/user/quick-start/#installation |
| `helm` ≥ 3.14 | https://helm.sh/docs/intro/install/ |
| `kubectl` | https://kubernetes.io/docs/tasks/tools/ |
| `go` ≥ 1.22 | https://go.dev/dl/ |

## Running the tests

```bash
# Run all test contexts (each gets its own Kind cluster)
CASTAI_API_KEY=<your-key> make e2e

# Run only kent mode
CASTAI_API_KEY=<your-key> make e2e-kent

# Run only autoscaler mode
CASTAI_API_KEY=<your-key> make e2e-autoscaler

# Run uninstall test
CASTAI_API_KEY=<your-key> make e2e-uninstall
```

## CI

The workflow file `.github/workflows/e2e.yml` runs each mode as a separate job in parallel.
Add your `CASTAI_API_KEY` as a GitHub Actions secret named `CASTAI_API_KEY`.

## Project layout

```
test/e2e/
├── suite_test.go       # Ginkgo entry point, BeforeSuite/AfterSuite
├── umbrella_test.go    # All test specs (kent, autoscaler, upgrade, uninstall)
├── helpers.go          # KindHelper, UmbrellaHelmHelper, PodHelper, NamespaceHelper
├── kind_helper.go      # Kind cluster lifecycle
├── utils/
│   └── utils.go        # Run(), GetNonEmptyLines()
├── go.mod
├── Makefile
└── README.md
```
