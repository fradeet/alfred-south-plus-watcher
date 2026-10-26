#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
# Alfred passes JSON as argv; notify reads stdin.
input_from_arg=false
if (($#)) && [[ $1 != -* ]]; then
  json=$1
  input_from_arg=true
  shift
fi
set -- notify "$@"
if [[ ${alfred_debug:-0} == 1 ]]; then
  set -- -vv "$@"
fi
if [[ $input_from_arg == true ]]; then
  exec "$workflow_dir/play-new-asmr-cli" "$@" <<< "$json"
fi
exec "$workflow_dir/play-new-asmr-cli" "$@"
