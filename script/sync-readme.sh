#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_file="$project_dir/alfred_workflow/README.md"
plist_file="$project_dir/alfred_workflow/info.plist"

plutil -replace readme -string "$(cat "$source_file")" "$plist_file"
printf 'Updated %s\n' "$plist_file"
