(
  set -eEuo pipefail
  trap 'printf "Error: Unable to fetch HTML.\n" >&2' ERR
  url=${args[--url]:-}
  if [[ -z $url ]]; then
    fid=${args[--fid]}
    [[ $fid =~ ^[0-9]+$ ]] || south_error 'Subforum ID must contain only digits.'
    base=$(south_base_url)
    url=${base}thread.php?fid-${fid}.html
  fi
  [[ $url =~ ^https://([a-zA-Z0-9.-]+)(:[0-9]+)?(/[^[:space:]]*)?$ ]] ||
    south_error 'Use an HTTPS URL without credentials or whitespace.'
  host=${BASH_REMATCH[1]}
  ua=${SOUTH_USER_AGENT:-'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'}
  [[ $ua != *$'\r'* && $ua != *$'\n'* ]] || south_error 'User-Agent must be a single line.'
  umask 077
  work=$(mktemp -d)
  trap 'rm -rf -- "$work"' EXIT
  if [[ -n ${SOUTH_COOKIE_FILE:-} ]]; then
    [[ -f $SOUTH_COOKIE_FILE && -r $SOUTH_COOKIE_FILE && -s $SOUTH_COOKIE_FILE ]] ||
      south_error 'SOUTH_COOKIE_FILE must be a readable, non-empty file.'
    cookie=$work/cookies.txt
    cp -- "$SOUTH_COOKIE_FILE" "$cookie"
  else
    [[ -n ${SOUTH_WINDUSER:-} ]] || south_error 'Set SOUTH_WINDUSER or SOUTH_COOKIE_FILE.'
    [[ $SOUTH_WINDUSER != *[[:space:]]* && $SOUTH_WINDUSER != *';'* ]] ||
      south_error 'SOUTH_WINDUSER must contain only the Cookie value.'
    cookie=$work/cookies.txt
    # Scope the Cookie to the requested host and keep it out of process arguments.
    printf '# Netscape HTTP Cookie File\n%s\tFALSE\t/\tTRUE\t0\teb9e6_winduser\t%s\n' \
      "$host" "$SOUTH_WINDUSER" > "$cookie"
  fi
  if ! curl -q --fail --silent --show-error --location --max-redirs 5 \
    --connect-timeout 10 --max-time 40 --proto '=https' --proto-redir '=https' \
    --user-agent "$ua" --cookie "$cookie" --output "$work/page.html" --url "$url"; then
    south_error 'Request failed; check the network, HTTP status and proxy settings.'
  fi
  south_check_page "$work/page.html"
  cat "$work/page.html"
)
