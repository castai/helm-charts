#!/usr/bin/env python3
"""
Set a value at a yq-style dotted path in a YAML file, preserving formatting.

Usage: bump-yaml-field.py <path> <new-value> <file>

  path       yq-style path, e.g. .version or .autoscaler."castai-agent".image.tag
  new-value  string value to set
  file       YAML file to update in-place
"""
import sys
import re
from ruamel.yaml import YAML

path_str, new_value, file_path = sys.argv[1], sys.argv[2], sys.argv[3]
keys = [a or b for a, b in re.findall(r'"([^"]+)"|([a-zA-Z0-9_-]+)', path_str.lstrip('.'))]

yaml = YAML()
yaml.preserve_quotes = True
with open(file_path) as f:
    doc = yaml.load(f)
obj = doc
for key in keys[:-1]:
    obj = obj[key]
obj[keys[-1]] = new_value
with open(file_path, 'w') as f:
    yaml.dump(doc, f)
