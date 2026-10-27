(
  set -euo pipefail
  page=$(south_fetch_forum "${args[forum_id]}")
  south_parse_forum "$page"
)
