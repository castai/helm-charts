"""Bump the patch version of a Chart.yaml and set its appVersion.

usage: bump_chart.py <Chart.yaml> [<appVersion>]

Only the top-level `version:` and `appVersion:` lines change. A plain string replace of the
version would also hit an appVersion or a dependency that contains the same digits.
"""
import re
import sys

if len(sys.argv) < 2 or sys.argv[1] == "":
    sys.exit("usage: bump_chart.py <Chart.yaml> [<appVersion>]")

chart_yaml_path = sys.argv[1]
new_app_version = sys.argv[2] if len(sys.argv) >= 3 else ""

with open(chart_yaml_path, "r") as chart_file:
    chart_yaml = chart_file.read()

match = re.search(r"^version:[ \t]*[\"']?(\d+)\.(\d+)\.(\d+)[\"']?[ \t]*$", chart_yaml, re.MULTILINE)
if not match:
    sys.exit(f"{chart_yaml_path}: no top-level 'version: x.y.z' line")
current_version = f"{match.group(1)}.{match.group(2)}.{match.group(3)}"
new_version = f"{match.group(1)}.{match.group(2)}.{int(match.group(3)) + 1}"
chart_yaml = chart_yaml[: match.start()] + f"version: {new_version}" + chart_yaml[match.end() :]
print(f"Current version: {current_version}")
print(f"Updated version: {new_version}")

if new_app_version != "":
    match = re.search(r"^appVersion:.*$", chart_yaml, re.MULTILINE)
    if match:
        print(f"Current appVersion: {match.group(0).split(':', 1)[1].strip()}")
        chart_yaml = chart_yaml[: match.start()] + f'appVersion: "{new_app_version}"' + chart_yaml[match.end() :]
    else:
        chart_yaml = chart_yaml.rstrip("\n") + f'\nappVersion: "{new_app_version}"\n'
    print(f'Updated appVersion: "{new_app_version}"')

with open(chart_yaml_path, "w") as chart_file:
    chart_file.write(chart_yaml)
