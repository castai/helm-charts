# Workload Autoscaler

The [Workload Autoscaler](https://docs.cast.ai/docs/workload-autoscaling-overview) Helm chart is published in the
[Cast AI Helm repository](https://castai.github.io/helm-charts). Since the source code is not directly available in this
repository, you can fetch the Helm chart using the following methods.

## Using `helm` CLI

Pull the chart manifest locally using Helm CLI.

### Prerequisites

1. [Install Helm CLI](https://helm.sh/docs/intro/install/).
2. Add the Cast AI Helm repository:
   ```sh
   helm repo add castai-helm https://castai.github.io/helm-charts
   ```

### Get the Latest Version

To fetch the latest available version of the Workload Autoscaler Helm chart, run:

```sh
helm pull castai-helm/castai-workload-autoscaler --untar --untardir /tmp/chart
```

### Get a Specific Version

To fetch a specific version, specify it using the `--version` flag:

```sh
helm pull castai-helm/castai-workload-autoscaler --untar --untardir /tmp/v0.1.62 --version 0.1.62
```

## Using `curl` CLI

If you don't have `helm` installed, you can download the Helm chart directly using `curl`.

> [!NOTE]
> Replace `0.1.64` with the desired version.

```sh
curl -s -L https://github.com/castai/helm-charts/releases/download/castai-workload-autoscaler-0.1.64/castai-workload-autoscaler-0.1.64.tgz | tar xvz -
```
