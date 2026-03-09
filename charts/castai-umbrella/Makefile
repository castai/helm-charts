CHART_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_ROOT := $(realpath $(CHART_DIR)/../..)
SUBCHARTS := $(wildcard $(CHART_DIR)/charts/*)

define BUMP_MINOR_VERSION
	bump_version() { \
		local chart_dir="$$1"; \
		local current=$$(grep '^version:' "$$chart_dir/Chart.yaml" | awk '{print $$2}'); \
		local major=$$(echo $$current | cut -d. -f1); \
		local minor=$$(echo $$current | cut -d. -f2); \
		local new="$$major.$$((minor + 1)).0"; \
		sed -i '' "s/^version: $$current/version: $$new/" "$$chart_dir/Chart.yaml"; \
		echo "    $$(basename $$chart_dir): $$current -> $$new"; \
	}
endef

.PHONY: update
update: ## Full update: bump versions, refresh deps, regenerate docs, lint, and validate.
	@echo "==> Bumping chart minor versions..."
	@$(BUMP_MINOR_VERSION) && \
		for subchart in $(SUBCHARTS); do \
			if [ -d "$$subchart" ] && [ -f "$$subchart/Chart.yaml" ]; then \
				bump_version "$$subchart"; \
			fi; \
		done && \
		bump_version "$(CHART_DIR)"
	@echo ""
	@echo "==> Adding helm repositories..."
	@helm repo add castai-helm https://castai.github.io/helm-charts 2>/dev/null || true
	@helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 2>/dev/null || true
	@helm repo update
	@for subchart in $(SUBCHARTS); do \
		if [ -d "$$subchart" ] && [ -f "$$subchart/Chart.yaml" ]; then \
			echo "==> Updating dependencies for subchart: $$(basename $$subchart)"; \
			helm dependency update "$$subchart"; \
		fi; \
	done
	@echo "==> Updating dependencies for umbrella chart"
	@helm dependency update $(CHART_DIR)
	@echo "==> All dependencies updated and locked."
	@echo ""
	@echo "==> Regenerating docs (via scripts/gen-docs.sh)..."
	@cd $(REPO_ROOT) && ./scripts/gen-docs.sh -c castai-umbrella
	@echo "==> Docs regenerated."
	@echo ""
	@echo "==> Linting charts..."
	@docker run --rm -i \
		-v $(REPO_ROOT):/repo \
		--workdir /repo \
		quay.io/helmpack/chart-testing:v3.6.0 \
		ct lint --debug --config ct.yaml --charts charts/castai-umbrella
	@echo "==> Lint passed."
	@echo ""
	@echo "==> Update complete. Ready for MR."
