local ua=${SOUTH_USER_AGENT:-'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'}
local cookie=${SOUTH_COOKIE_FILE:-"eb9e6_winduser=${SOUTH_WINDUSER:-}"}

curl -sS -L --user-agent "$ua" --cookie "$cookie" --url "${args[--url]}"
