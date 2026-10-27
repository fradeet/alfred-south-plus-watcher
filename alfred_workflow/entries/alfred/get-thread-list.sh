#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)

other_args=()

if [[ $alfred_debug ]]; then
    other_args+=(-vv)
fi

exec "$workflow_dir/south-plus-cli" "${other_args[@]}" forum view --output-format alfred-json -- 128
