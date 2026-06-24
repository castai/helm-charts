#!/usr/bin/env python3
"""
Set a scalar value at a yq-style dotted path in a YAML file using
line-by-line string replacement. Does NOT parse or re-serialize the YAML,
so the file's formatting, comments, and ordering are completely preserved.

Usage: bump-yaml-field.py <path> <new-value> <file>

  path       yq-style path, e.g.:
               .version
               .autoscaler."castai-agent".image.tag
               .autoscaler."castai-live".daemon.image.tag
  new-value  string value to write
  file       YAML file to update in-place

Algorithm:
  Walks the key segments top-to-bottom, tracking indentation to stay in the
  right nested block. When the final key is found at the expected indent level,
  replaces only its value — preserving surrounding quotes if present.
  Exits 1 if the path cannot be found.
"""

import re
import sys


def parse_keys(path_str: str) -> list[str]:
    """Parse a yq-style dotted path into a list of key strings."""
    return [a or b for a, b in re.findall(r'"([^"]+)"|([a-zA-Z0-9_-]+)', path_str.lstrip("."))]


def find_key_line(lines: list[str], key: str, start: int, min_indent: int, max_indent: int | None) -> tuple[int, int]:
    """
    Find the next line matching `<indent><key>:` within [start, end).
    indent must be >= min_indent and (if max_indent set) == max_indent.
    Returns (line_index, indent_of_that_line).
    Raises ValueError if not found.
    """
    pattern = re.compile(rf'^( *){re.escape(key)}\s*:')
    for i in range(start, len(lines)):
        m = pattern.match(lines[i])
        if not m:
            continue
        indent = len(m.group(1))
        if indent < min_indent:
            # We've de-dented past where the key could live — stop searching.
            raise ValueError(f"Key '{key}' not found (de-indented past min_indent={min_indent} at line {i+1})")
        if max_indent is not None and indent != max_indent:
            continue
        return i, indent
    raise ValueError(f"Key '{key}' not found after line {start+1}")


def replace_scalar_value(lines: list[str], line_idx: int, new_value: str) -> None:
    """
    Replace the scalar value on a `key: <value>` line in-place.
    Preserves surrounding quotes if the original value was quoted.
    Handles both inline values (key: value) and block scalars (key: |).
    """
    line = lines[line_idx]
    # Match:  <indent><key>: ["']?<value>["']?<trailing>
    m = re.match(r'^( *\S[^:]*:\s*)(["\']?)(.+?)(["\']?)(\s*)$', line)
    if not m:
        raise ValueError(f"Cannot parse scalar on line {line_idx+1}: {line!r}")

    prefix, open_q, _old_val, close_q, trailing = m.groups()

    # If original had matching quotes, preserve them; otherwise write bare.
    if open_q and open_q == close_q:
        lines[line_idx] = f"{prefix}{open_q}{new_value}{close_q}{trailing}\n"
    else:
        lines[line_idx] = f"{prefix}{new_value}{trailing}\n"


def main() -> None:
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <path> <new-value> <file>", file=sys.stderr)
        sys.exit(1)

    path_str, new_value, file_path = sys.argv[1], sys.argv[2], sys.argv[3]
    keys = parse_keys(path_str)

    with open(file_path) as f:
        lines = f.readlines()

    cursor = 0          # current search start line
    indent = 0          # expected indent of next key (None = any)
    exact_indent = None # None until we've seen the first key

    for depth, key in enumerate(keys):
        is_last = depth == len(keys) - 1
        line_idx, found_indent = find_key_line(lines, key, cursor, indent, exact_indent)

        if is_last:
            replace_scalar_value(lines, line_idx, new_value)
        else:
            # Descend: next key must be indented more than current key.
            cursor = line_idx + 1
            indent = found_indent + 1
            exact_indent = None   # don't know exact child indent yet; find_key_line will set it on first match

    with open(file_path, "w") as f:
        f.writelines(lines)

    print(f"Updated {path_str} = {new_value!r} in {file_path}")


if __name__ == "__main__":
    main()
