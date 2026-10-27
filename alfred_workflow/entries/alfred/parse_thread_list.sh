#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
# Alfred passes the previous action's output as argv; the CLI reads stdin.
if (($#)) && [[ $1 != -* ]]; then
  exec <<< "$1"
  shift
fi
set -- parse-thread-list "$@"
if [[ ${alfred_debug:-0} == 1 ]]; then
  set -- -vv "$@"
fi
exec "$workflow_dir/play-new-asmr-cli" "$@"
