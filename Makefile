REPO_ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

.PHONY: help
help: ## Shows this help message.
	@echo "Usage:"
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sed -e 's/^/  make /' | column -s: -t
	@echo

.PHONY: lint-all
lint-all: ## Lint all charts in the 'charts' directory.
	docker run --rm -i  \
		-v $(REPO_ROOT):/repo \
		--workdir /repo \
		quay.io/helmpack/chart-testing:v3.6.0 \
		ct lint --debug --config ct.yaml --all

.PHONY: validate
validate: ## Validate the PR.
	scripts/validate-pr.sh

.PHONY: docs-all
docs-all: ## Generate helm docs for all charts in the 'charts' directory.
	./scripts/gen-docs.sh

# Generate a target for each chart in the 'charts' directory
CHART_NAMES=$(notdir $(wildcard charts/*))
$(addprefix docs-, $(CHART_NAMES)): docs-%: charts/%
	@echo "Generating helm docs for chart: $*"
	./scripts/gen-docs.sh -c $*
.PHONY: $(addprefix docs-, $(CHART_NAMES))

# Add documentation for the dynamic docs targets to the help.
docs-<chart_name>: ## Generate helm docs for a specific chart, e.g., 'make docs-castai-agent'
