import re
import sys

if len(sys.argv) < 2 or sys.argv[1] == "":
    raise Exception("Chart.yaml path should be passed as first argument")

if len(sys.argv) < 3 or sys.argv[2] == "":
    raise Exception("Release tag should be passed as second argument")

chart_yaml_path = sys.argv[1]
release_tag = sys.argv[2]

# Extract version from tag (v0.1.2 -> 0.1.2)
new_version = release_tag.lstrip('v')

with open(chart_yaml_path, "r") as chart_file:
    chart_yaml = chart_file.read()

updated_yaml = chart_yaml

# Update version to match release tag
match = re.search(r"version:\s*(.+)", chart_yaml)
if match:
    current_version = match.group(1)
    print(f"Current version: {current_version}")

    if current_version != new_version:
        updated_yaml = re.sub(r"(version:\s*).+", f"\g<1>{new_version}", updated_yaml)
        print(f"Updated version: {new_version}")
    else:
        print(f"Version already matches: {new_version}")

# Update appVersion to match release tag
match = re.search(r"appVersion:\s*(.+)", chart_yaml)
if match:
    current_app_version = match.group(1).strip('"')
    print(f"Current appVersion: {current_app_version}")

    if current_app_version != release_tag:
        updated_yaml = re.sub(
            r"(appVersion:\s*).+", f'\\g<1>"{release_tag}"', updated_yaml
        )
        print(f'Updated appVersion: "{release_tag}"')
    else:
        print(f"appVersion already matches: {release_tag}")

with open(chart_yaml_path, "w") as chart_file:
    chart_file.write(updated_yaml)
