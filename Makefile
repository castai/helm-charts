REPO_ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

lint-all:
	docker run --rm -i  \
		-v $(REPO_ROOT):/repo \
		--workdir /repo \
		quay.io/helmpack/chart-testing:v3.6.0 \
		ct lint --debug --config ct.yaml --all

validate:
	scripts/validate-pr.sh
