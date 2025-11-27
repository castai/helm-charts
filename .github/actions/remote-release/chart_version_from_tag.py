import re
import sys

# SemVer regex pattern
SEMVER_PATTERN = re.compile(
    r"^(\d+)\.(\d+)\.(\d+)"
    r"(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?"
    r"(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?$"
)


def is_valid_semver(version: str) -> bool:
    """Check if the version string follows SemVer format."""
    # Strip optional 'v' prefix before validation
    version_to_check = version.lstrip("v")
    return bool(SEMVER_PATTERN.match(version_to_check))


def update_version(chart_yaml: str, new_version: str, chart_yaml_path: str) -> str:
    """Update the version field in Chart.yaml content."""
    match = re.search(r"^version:\s*(.+)$", chart_yaml, re.IGNORECASE | re.MULTILINE)
    if not match:
        raise ValueError(f"No 'version' field found in {chart_yaml_path}")

    current_version = match.group(1)
    print(f"Current version: {current_version}")

    if current_version != new_version:
        chart_yaml = re.sub(
            r"^(version:\s*).+$",
            f"\\g<1>{new_version}",
            chart_yaml,
            flags=re.IGNORECASE | re.MULTILINE,
        )
        print(f"Updated version: {new_version}")
    else:
        print(f"Version already matches: {new_version}")

    return chart_yaml


def update_app_version(chart_yaml: str, release_tag: str) -> str:
    """Update the appVersion field in Chart.yaml content."""
    match = re.search(r"appVersion:\s*(.+)", chart_yaml, re.IGNORECASE)
    if not match:
        return chart_yaml

    current_app_version = match.group(1).strip('"')
    print(f"Current appVersion: {current_app_version}")

    if current_app_version != release_tag:
        chart_yaml = re.sub(
            r"(appVersion:\s*).+",
            f'\\g<1>"{release_tag}"',
            chart_yaml,
            flags=re.IGNORECASE,
        )
        print(f'Updated appVersion: "{release_tag}"')
    else:
        print(f"appVersion already matches: {release_tag}")

    return chart_yaml


def main() -> None:
    if len(sys.argv) < 2 or sys.argv[1] == "":
        raise ValueError("Chart.yaml path should be passed as first argument")

    if len(sys.argv) < 3 or sys.argv[2] == "":
        raise ValueError("Release tag should be passed as second argument")

    chart_yaml_path = sys.argv[1]
    release_tag = sys.argv[2]

    # Validate release tag is a valid SemVer
    if not is_valid_semver(release_tag):
        raise ValueError(
            f"Invalid version format: '{release_tag}'. "
            "Expected SemVer format (e.g., v1.2.3, 1.2.3, v1.2.3-rc.1)"
        )

    # Extract version from tag (v0.1.2 -> 0.1.2)
    new_version = release_tag.lstrip("v")

    with open(chart_yaml_path, "r") as chart_file:
        chart_yaml = chart_file.read()

    chart_yaml = update_version(chart_yaml, new_version, chart_yaml_path)
    chart_yaml = update_app_version(chart_yaml, release_tag)

    with open(chart_yaml_path, "w") as chart_file:
        chart_file.write(chart_yaml)


if __name__ == "__main__":
    main()
