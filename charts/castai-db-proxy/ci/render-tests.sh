#!/usr/bin/env bash
#
# Render tests for castai-db-proxy.
#
# Renders the chart for each ci/*-values.yaml scenario and asserts how the
# read-only path is exposed (the available-address config in config.toml and
# the dedicated -ro Service):
#
#   test-values.yaml                      Oracle, rw-only     -> no RO, no -ro svc (port 1521)
#   postgres-readonly-values.yaml         pg, rw+ro           -> RO address + -ro svc (port 5432)
#   postgres-rw-only-values.yaml          pg, rw-only         -> no RO, no -ro svc (port 5432)
#   postgres-pgdog-readonly-values.yaml   pg + pgdog pooling  -> no RO, no -ro svc (port 5432)
#   mysql-pooling-readonly-values.yaml    mysql + ProxySQL    -> RO address + -ro svc (port 3306)
#   mysql-pooling-rw-only-values.yaml     mysql, no ro        -> no RO, no -ro svc (port 3306)
#
# The read-write available address is expected in every scenario: the release
# service always exists and db-proxy accepts proxy_available_address
# unconditionally. The rendered proxy config.toml is also validated as TOML,
# so template regressions that only surface as a proxy crashloop at deploy
# time are caught here.
#
# Requires helm and python3 (>= 3.11, for tomllib).

set -euo pipefail

CHART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="ci-render-ns"
CHART_NAME="castai-db-proxy"
RO_SERVICE="${CHART_NAME}-ro"

pass=0
fail=0

expect_contains() {
    local haystack="$1" needle="$2" message="$3"
    if grep -qF -- "$needle" <<<"$haystack"; then
        echo "  ok: $message"
        pass=$((pass + 1))
    else
        echo "  FAIL: $message"
        echo "       expected to find: $needle"
        fail=$((fail + 1))
    fi
}

expect_not_contains() {
    local haystack="$1" needle="$2" message="$3"
    if grep -qF -- "$needle" <<<"$haystack"; then
        echo "  FAIL: $message"
        echo "       expected NOT to find: $needle"
        fail=$((fail + 1))
    else
        echo "  ok: $message"
        pass=$((pass + 1))
    fi
}

# Extract the proxy config.toml from the rendered ConfigMap. Blank lines are
# part of the block scalar; the first non-indented line ends it.
extract_config_toml() {
    awk '
        /^  name: castai-db-proxy-config$/ { in_configmap = 1 }
        in_configmap && /^  config.toml: \|$/ { in_config = 1; next }
        in_config && /^    / { print substr($0, 5); next }
        in_config && /^[[:space:]]*$/ { print ""; next }
        in_config { exit }
    ' <<<"$1"
}

check_config_toml() {
    local toml
    toml="$(extract_config_toml "$1")"
    if python3 -c 'import sys, tomllib; tomllib.loads(sys.stdin.read())' <<<"$toml"; then
        echo "  ok: config.toml is valid TOML"
        pass=$((pass + 1))
    else
        echo "  FAIL: config.toml is not valid TOML"
        fail=$((fail + 1))
    fi
}

scenario() {
    local values="$1" service_port="$2" readonly="$3"
    echo "scenario: $values (service port $service_port, read-only: $readonly)"
    local rendered
    if ! rendered=$(helm template ci-render "$CHART_DIR" -n "$NAMESPACE" -f "$CHART_DIR/ci/$values"); then
        echo "  FAIL: helm template failed for $values"
        fail=$((fail + 1))
        echo
        return
    fi

    expect_contains "$rendered" \
        "proxy_available_address = \"${CHART_NAME}.${NAMESPACE}:${service_port}\"" \
        "read-write available address advertises the release service on the protocol port"

    if [[ "$readonly" == "true" ]]; then
        expect_contains "$rendered" \
            "proxy_available_ro_address = \"${RO_SERVICE}.${NAMESPACE}:${service_port}\"" \
            "read-only available address advertises the -ro service"
        expect_contains "$rendered" \
            "  name: ${RO_SERVICE}" \
            "dedicated -ro service is deployed"
    else
        expect_not_contains "$rendered" \
            "proxy_available_ro_address" \
            "no read-only available address is configured"
        expect_not_contains "$rendered" \
            "  name: ${RO_SERVICE}" \
            "no dedicated -ro service is deployed"
    fi

    check_config_toml "$rendered"
    echo
}

scenario test-values.yaml 1521 false
scenario postgres-readonly-values.yaml 5432 true
scenario postgres-rw-only-values.yaml 5432 false
scenario postgres-pgdog-readonly-values.yaml 5432 false
scenario mysql-pooling-readonly-values.yaml 3306 true
scenario mysql-pooling-rw-only-values.yaml 3306 false

echo "passed: $pass, failed: $fail"
if [[ "$fail" -gt 0 ]]; then
    exit 1
fi
