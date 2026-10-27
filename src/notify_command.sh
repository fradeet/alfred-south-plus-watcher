(
  set -euo pipefail
  jq -csr --arg watch "${PNA_WATCH_LIST:-}" '
    if length != 1 then error("Expected one JSON array") else .[0] end |
    ($watch | split("\n") | map(gsub("^\\s+|\\s+$"; "")) |
      map(select(length > 0)) | unique) as $keywords |
    if type != "array" then error("Expected a JSON array of titles or threads")
    else map(
      if type == "string" then .
      elif type == "object" and (.title | type) == "string" then .title
      else error("Each item must be a title string or an object with a title")
      end
    ) end |
    .[] | select(. as $title |
      any($keywords[]; . as $keyword | $title | contains($keyword)))
  '
)
