#!/usr/bin/env bash
set -euo pipefail

# Alfred expands alfredworkflow.arg into URL-tab-title arguments.
if ! result=$(jq -cn --arg watch "${PNA_WATCH_LIST:-}" --args '
  ($watch | split("\n") | map(gsub("^\\s+|\\s+$"; "") |
    select(length > 0)) | unique) as $keywords |
  {alfredworkflow: {arg: ($ARGS.positional | map(
    index("\t") as $tab |
    if $tab == null then
      error("Expected a URL and title separated by a tab")
    else
      {url: .[:$tab], title: .[$tab + 1:]}
    end |
    select(.title as $title |
      any($keywords[]; . as $keyword | $title | contains($keyword))) |
    .title
  ))}}
' -- "$@"); then
  exit 1
fi

printf '%s\n' "$result"
