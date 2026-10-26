#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
if [[ ${alfred_debug:-0} == 1 ]]; then
  exec "$workflow_dir/play-new-asmr-cli" -vv parse-thread-list "$@"
fi
exec "$workflow_dir/play-new-asmr-cli" parse-thread-list "$@"
