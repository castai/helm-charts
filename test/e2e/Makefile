# Makefile for castai-umbrella e2e tests
#
# Prerequisites:
#   - kind    https://kind.sigs.k8s.io/
#   - helm    https://helm.sh/
#   - kubectl
#   - go 1.22+
#
# Usage:
#   CASTAI_API_KEY=<your-key> make e2e
#   CASTAI_API_KEY=<your-key> make e2e-kent
#   CASTAI_API_KEY=<your-key> make e2e-autoscaler

.PHONY: e2e e2e-kent e2e-autoscaler e2e-upgrade e2e-uninstall deps tidy

# Run all e2e tests (each context creates its own Kind cluster)
e2e:
	go test ./... -v -timeout 60m

# Run only the kent mode tests
e2e-kent:
	go test ./... -v -timeout 30m --ginkgo.focus="kent mode"

# Run only the autoscaler mode tests
e2e-autoscaler:
	go test ./... -v -timeout 30m --ginkgo.focus="autoscaler mode"

# Run only the upgrade tests
e2e-upgrade:
	go test ./... -v -timeout 30m --ginkgo.focus="in-place upgrade"

# Run only the uninstall tests
e2e-uninstall:
	go test ./... -v -timeout 30m --ginkgo.focus="clean uninstall"

# Download Go module dependencies
deps:
	go mod download

# Tidy Go modules
tidy:
	go mod tidy
