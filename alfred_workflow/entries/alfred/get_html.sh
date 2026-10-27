#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
# Alfred passes an empty query as the first argument.
if (($#)) && [[ -z $1 ]]; then
  shift
fi
if [[ ${alfred_debug:-0} == 1 ]]; then
  base=${SOUTH_BASE_URL:-https://spring-plus.net/}
  exec "$workflow_dir/play-new-asmr-cli" -vv get-html --url "${base%/}/thread.php?fid-128.html" "$@"
fi
exec "$workflow_dir/play-new-asmr-cli" get-html "$@"
