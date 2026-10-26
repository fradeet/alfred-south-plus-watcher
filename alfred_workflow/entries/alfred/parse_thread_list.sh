#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
# Alfred passes the previous action's output as argv; the CLI reads stdin.
input_from_arg=false
if (($#)) && [[ $1 != -* ]]; then
  html=$1
  input_from_arg=true
  shift
fi
set -- parse-thread-list "$@"
if [[ ${alfred_debug:-0} == 1 ]]; then
  set -- -vv "$@"
fi
if [[ $input_from_arg == true ]]; then
  exec "$workflow_dir/play-new-asmr-cli" "$@" <<< "$html"
fi
exec "$workflow_dir/play-new-asmr-cli" "$@"
