#!/usr/bin/env python3
"""
Update a dependency's version in a Chart.yaml dependencies list,
preserving the file's exact formatting.

Usage: bump-chart-dep.py <dep-name> <new-version> <Chart.yaml-path>
"""
import sys

name, version, path = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(path).readlines()
for i, line in enumerate(lines):
    if f'name: {name}' in line:
        for j in range(i + 1, min(i + 6, len(lines))):
            stripped = lines[j].lstrip()
            if stripped.startswith('version:'):
                indent = len(lines[j]) - len(stripped)
                lines[j] = ' ' * indent + f'version: {version}\n'
                break
        break
open(path, 'w').writelines(lines)
