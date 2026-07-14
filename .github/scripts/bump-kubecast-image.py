#!/usr/bin/env python3
"""
Bumps a component's image.tag in castai-cluster-agent/chart/values.yaml
and increments the patch version in Chart.yaml, preserving file formatting.

Usage:
    bump-kubecast-image.py <values.yaml> <Chart.yaml> <component> <image_tag>

Exits 0 with "changed=false" output when the tag is already up to date.
Exits 0 with "changed=true" and "new_version=x.y.z" output on success.
"""

import re
import sys


def bump_patch(version):
    parts = version.strip().split(".")
    if len(parts) != 3 or not parts[2].isdigit():
        print(f"Unexpected version format: {version!r} (expected x.y.z)", file=sys.stderr)
        sys.exit(1)
    return f"{parts[0]}.{parts[1]}.{int(parts[2]) + 1}"


def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <values.yaml> <Chart.yaml> <component> <image_tag>", file=sys.stderr)
        sys.exit(1)

    values_path, chart_path, component, image_tag = sys.argv[1:]

    with open(values_path) as f:
        values = f.read()

    # Find the component's block (ends at the next top-level key or EOF),
    # then locate image.tag within that block only — no cross-boundary matching.
    block_pattern = rf"(?m)^{re.escape(component)}:\n((?:[ \t].*\n|\n)*)"
    block_match = re.search(block_pattern, values)
    if not block_match:
        print(f"Could not find component {component!r} in {values_path}", file=sys.stderr)
        sys.exit(1)

    block_start = block_match.start(1)
    block = block_match.group(1)

    # Within the block, find image: stanza then tag: — constrained to 4-space indent.
    tag_pattern = r"(?m)^  image:\n(?:    (?!tag:).*\n)*    tag:\s*([\"']?)(\S+?)\1\s*$"
    tag_match = re.search(tag_pattern, block)
    if not tag_match:
        print(f"Could not find {component}.image.tag in {values_path}", file=sys.stderr)
        sys.exit(1)

    quote = tag_match.group(1)
    current_tag = tag_match.group(2)
    if current_tag == image_tag:
        print(f"Image tag is already {image_tag} — nothing to do.")
        print("changed=false")
        sys.exit(0)

    # Compute replacement at the absolute position in the full file.
    abs_start = block_start + tag_match.start(1)
    abs_end = block_start + tag_match.end(2)
    new_values = values[:abs_start] + quote + image_tag + quote + values[abs_end:]

    with open(chart_path) as f:
        chart = f.read()

    version_match = re.search(r"(?m)^version:\s*(\S+)", chart)
    if not version_match:
        print(f"Could not find version in {chart_path}", file=sys.stderr)
        sys.exit(1)

    current_version = version_match.group(1)
    new_version = bump_patch(current_version)
    new_chart = chart[: version_match.start(1)] + new_version + chart[version_match.end(1) :]

    # Both mutations validated — safe to write.
    with open(values_path, "w") as f:
        f.write(new_values)
    with open(chart_path, "w") as f:
        f.write(new_chart)

    print(f"Bumped {component} image: {current_tag} -> {image_tag}")
    print(f"Bumped chart version: {current_version} -> {new_version}")
    print("changed=true")
    print(f"old_tag={current_tag}")
    print(f"new_version={new_version}")


if __name__ == "__main__":
    main()