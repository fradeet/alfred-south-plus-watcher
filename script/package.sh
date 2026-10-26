#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
workflow_dir="$project_dir/alfred_workflow"
output_file=${1:-"$project_dir/Alfred Bashly Template.alfredworkflow"}

"$project_dir/script/sync-cli.sh"
"$project_dir/script/sync-readme.sh"
plutil -lint "$workflow_dir/info.plist" >/dev/null

case "$output_file" in
  /*) ;;
  *) output_file="$PWD/$output_file" ;;
esac

temporary_dir=$(mktemp -d "${TMPDIR:-/tmp}/alfred-workflow.XXXXXX")
trap 'rm -rf "$temporary_dir"' EXIT
temporary_file="$temporary_dir/workflow.alfredworkflow"

(cd "$workflow_dir" && zip -q -r "$temporary_file" info.plist README.md template-cli entries -x '*.DS_Store')
mv -f "$temporary_file" "$output_file"
printf 'Created %s\n' "$output_file"
