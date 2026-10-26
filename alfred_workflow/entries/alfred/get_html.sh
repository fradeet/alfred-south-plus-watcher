#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
other_args=()
[[ ${alfred_debug:-} ]] && other_args+=(-vv)

exec "$workflow_dir/play-new-asmr-cli" "${other_args[@]}" get-html "$@"
