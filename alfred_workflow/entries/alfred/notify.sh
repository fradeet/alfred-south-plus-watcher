#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
# Alfred expands alfredworkflow.arg into URL-tab-title arguments.
threads=()
while (($#)) && [[ $1 != -* ]]; do
  if [[ $1 != *$'\t'* ]]; then
    printf 'Error: Expected a URL and title separated by a tab.\n' >&2
    exit 1
  fi
  threads+=("$1")
  shift
done
json=$(jq -cn --args '
  $ARGS.positional | map(index("\t") as $tab |
    {url: .[:$tab], title: .[$tab + 1:]})
' -- "${threads[@]}")
set -- notify "$@"
if [[ ${alfred_debug:-0} == 1 ]]; then
  set -- -vv "$@"
fi
exec "$workflow_dir/play-new-asmr-cli" "$@" <<< "$json"
