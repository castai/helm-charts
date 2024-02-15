# CAST AI Kubernetes helm charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add castai-helm https://castai.github.io/helm-charts
```

You can then run `helm search repo castai-helm` to see the charts.

## Contribution

Updates to helm charts should also contain doc updates. 
We use [helm-docs](https://github.com/norwoodj/helm-docs) to generate docs. 

To install helm-docs, run:

```console
brew install norwoodj/tap/helm-docs
```

To generate docs, run:

```console
cd charts/CHART_NAME
helm-docs
```

## License

<!-- Keep full URL links to repo files because this README syncs from main to gh-pages.  -->
[Apache 2.0 License](https://github.com/castai/helm-charts/blob/main/LICENSE).
