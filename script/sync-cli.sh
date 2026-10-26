#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_dir"

command -v bashly >/dev/null || { echo 'bashly is required' >&2; exit 1; }
bashly generate
install -m 755 "$project_dir/template-cli" "$project_dir/alfred_workflow/template-cli"
printf 'Updated %s\n' "$project_dir/alfred_workflow/template-cli"
