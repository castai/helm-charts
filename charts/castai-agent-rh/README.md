# CAST AI Kubernetes Agent

A component that connects your Kubernetes cluster to the [CAST AI](https://www.cast.ai) platform to enable Kubernetes automation and cost optimization features.

## Getting started

Visit the [docs](https://docs.cast.ai/getting-started/overview/) to connect your cluster.

## Validate for RedHat helm chart certification

**Run the following in the repository root**:

```sh
docker run -v ${PWD}/charts:/charts -it --rm quay.io/redhat-certification/chart-verifier verify /charts/castai-agent -F /charts/castai-agent/values.yaml
```