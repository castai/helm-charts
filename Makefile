REPO_ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

lint-all:
	docker run --rm -i  \
		-v $(REPO_ROOT):/repo \
		--workdir /repo \
		quay.io/helmpack/chart-testing:v3.6.0 \
		ct lint --debug --config ct.yaml --all


# https://helm.sh/docs/topics/provenance/
# https://github.com/keybase/keybase-issues/issues/4025 
# gpg --default-new-key-algo rsa4096 --gen-key
package-rh-chart:
	helm package --sign --key "security@cast.ai" --keyring ./charts/secring.gpg ./charts/castai-agent-rh/ --destination ./charts/
verify-rh-chart:
	docker run -v ${PWD}/charts:/charts -it --rm quay.io/redhat-certification/chart-verifier -k /charts/pubring.gpg verify /charts/castai-agent-0.50.1.tgz 