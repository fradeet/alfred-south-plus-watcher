(
  set -euo pipefail
  if result=$(south_fetch_forum "${args[forum_id]}") &&
    result=$(south_parse_forum "$result"); then
    printf '%s\n' "$result"
  else
    printf 'Error: %s\n' "$result" >&2
    jq -cn --arg error_msg "$result" \
      '{alfredworkflow: {arg: "", variables: {success: false, error_msg: $error_msg}}}'
    exit 1
  fi
)
