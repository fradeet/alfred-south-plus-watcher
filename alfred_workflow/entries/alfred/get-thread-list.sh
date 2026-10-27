#!/usr/bin/env bash
set -euo pipefail

workflow_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
source "$workflow_dir/entries/lib/alfred_default_error.sh"

other_args=()

if [[ $alfred_debug ]]; then
    other_args+=(-vv)
fi

if ! result=$("$workflow_dir/south-plus-cli" "${other_args[@]}" forum view --output-format alfred-json -- 128); then
  exit 1
fi

printf '%s\n' "$result"
