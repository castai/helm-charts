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


def replace_preserving_format(content, pattern, replacement):
    match = re.search(pattern, content)
    if not match:
        print(f"Pattern not found: {pattern}", file=sys.stderr)
        sys.exit(1)
    return content[: match.start(1)] + replacement + content[match.end(1) :]


def bump_patch(version):
    parts = version.strip().split(".")
    return f"{parts[0]}.{parts[1]}.{int(parts[2]) + 1}"


def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <values.yaml> <Chart.yaml> <component> <image_tag>", file=sys.stderr)
        sys.exit(1)

    values_path, chart_path, component, image_tag = sys.argv[1:]

    with open(values_path) as f:
        values = f.read()

    # Find current tag under the component block.
    # Matches:  <component>:\n  ...\n    image:\n      tag: <value>
    pattern = rf"(?m)^{re.escape(component)}:.*?image:\s*\n\s+tag:\s*(\S+)"
    match = re.search(pattern, values, re.DOTALL)
    if not match:
        print(f"Could not find {component}.image.tag in {values_path}", file=sys.stderr)
        sys.exit(1)

    current_tag = match.group(1).strip('"').strip("'")
    if current_tag == image_tag:
        print(f"Image tag is already {image_tag} — nothing to do.")
        print("changed=false")
        sys.exit(0)

    values = values[: match.start(1)] + image_tag + values[match.end(1) :]
    with open(values_path, "w") as f:
        f.write(values)

    with open(chart_path) as f:
        chart = f.read()

    version_match = re.search(r"(?m)^version:\s*(\S+)", chart)
    if not version_match:
        print(f"Could not find version in {chart_path}", file=sys.stderr)
        sys.exit(1)

    current_version = version_match.group(1)
    new_version = bump_patch(current_version)
    chart = chart[: version_match.start(1)] + new_version + chart[version_match.end(1) :]
    with open(chart_path, "w") as f:
        f.write(chart)

    print(f"Bumped {component} image: {current_tag} -> {image_tag}")
    print(f"Bumped chart version: {current_version} -> {new_version}")
    print("changed=true")
    print(f"old_tag={current_tag}")
    print(f"new_version={new_version}")


if __name__ == "__main__":
    main()