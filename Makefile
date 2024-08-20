REPO_ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make lint-all                  Lint all charts in the 'charts' directory."
	@echo "  make validate                  Validate the PR."
	@echo "  make docs-all                  Generate helm docs for all charts in the 'charts' directory."
	@echo "  make docs-<chart_name>         Generate helm docs for a specific chart, e.g. 'make docs-castai-agent'."

.PHONY: lint-all
lint-all:
	docker run --rm -i  \
		-v $(REPO_ROOT):/repo \
		--workdir /repo \
		quay.io/helmpack/chart-testing:v3.6.0 \
		ct lint --debug --config ct.yaml --all

.PHONY: validate
validate:
	scripts/validate-pr.sh

.PHONY: docs-all
docs-all:
	./scripts/gen-docs.sh

# Generate a target for each chart in the 'charts' directory
CHART_NAMES=$(notdir $(wildcard charts/*))
$(addprefix docs-, $(CHART_NAMES)): docs-%: charts/%
	@echo "Generating helm docs for chart: $*"
	./scripts/gen-docs.sh -c $*
.PHONY: $(addprefix docs-, $(CHART_NAMES))
