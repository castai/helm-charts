#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="$(pwd)/child-charts"
REPO_URL="github.com/vllm-project/aibrix"
REPO_KUSTOMIZE_COMPONENT_PATH="config/standalone/autoscaler-controller"
REPO_TAG="0ca6da25cc3915015fbfd756637a22341d62b50f"
CHART_VERSION="0.1.0"
CHART_NAME="aibrix"
CHART_YAML="$OUT_DIR/$CHART_NAME/Chart.yaml"

echo "📦 Creating Helm chart with helmify..."
cd "$OUT_DIR"
kustomize build "$REPO_URL/$REPO_KUSTOMIZE_COMPONENT_PATH?ref=$REPO_TAG" | helmify -crd-dir "$CHART_NAME"

echo "🔧 Updating chart version in Chart.yaml..."
yq e -i ".appVersion = \"$REPO_TAG\"" "$CHART_YAML"
yq e -i ".version = \"$CHART_VERSION\"" "$CHART_YAML"

echo "✅ Helm chart created and updated at: $OUT_DIR/$CHART_NAME"