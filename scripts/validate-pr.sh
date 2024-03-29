#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${PR_TITLE:?Environment variable must be set}"

main() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel)

    local changed
    changed=$(ct list-changed --config "$repo_root/ct.yaml")

    if [[ -z "$changed" ]]; then
        exit 0
    fi

    local num_changed
    num_changed=$(wc -l <<< "$changed")

    if ((num_changed > 1)); then
        echo "This PR has changes to multiple charts. Please create individual PRs per chart." >&2
        exit 1
    fi

    # Strip charts directory
    changed="${changed##*/}"

    if [[ "$PR_TITLE" != "[$changed] "* ]]; then
        echo "PR title must start with '[$changed] '." >&2
        exit 1
    fi

    if [[ -f charts/$changed/README.md ]]; then
      cd charts/"$changed"
      if [[ ! -f README.md.gotmpl ]]; then
        helm-docs -t ../../scripts/README.md.gotmpl
      else
        helm-docs
      fi
      if [[ $(git diff --stat) != '' ]]; then
        echo "Readme for chart wasn't updated. Please use helm-docs and update it"
        echo "Diff:"
        git diff
        exit 1
      else
        echo 'helm-docs generation check: OK'
      fi
    fi

}

main
