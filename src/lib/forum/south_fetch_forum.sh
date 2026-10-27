south_fetch_forum() {
  local fid=$1 base url host ua cookie_data page
  [[ $fid =~ ^[0-9]+$ ]] || south_error 'Subforum ID must contain only digits.'
  base=$(south_base_url)
  url=${base}thread.php?fid-${fid}.html
  [[ $url =~ ^https://([a-zA-Z0-9.-]+)(:[0-9]+)?(/[^[:space:]]*)?$ ]] ||
    south_error 'Use an HTTPS URL without credentials or whitespace.'
  host=${BASH_REMATCH[1]}
  ua=${SP_USER_AGENT:-'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'}
  [[ $ua != *$'\r'* && $ua != *$'\n'* ]] || south_error 'User-Agent must be a single line.'
  if [[ -n ${SP_COOKIE_FILE:-} ]]; then
    [[ -f $SP_COOKIE_FILE && -r $SP_COOKIE_FILE && -s $SP_COOKIE_FILE ]] ||
      south_error 'SP_COOKIE_FILE must be a readable, non-empty file.'
    cookie_data=$(< "$SP_COOKIE_FILE")
  else
    [[ -n ${SP_WINDUSER:-} ]] || south_error 'Set SP_WINDUSER or SP_COOKIE_FILE.'
    [[ $SP_WINDUSER != *[[:space:]]* && $SP_WINDUSER != *';'* ]] ||
      south_error 'SP_WINDUSER must contain only the Cookie value.'
    # Scope the Cookie to the requested host and pass it through stdin.
    printf -v cookie_data '# Netscape HTTP Cookie File\n%s\tFALSE\t/\tTRUE\t0\teb9e6_winduser\t%s\n' \
      "$host" "$SP_WINDUSER"
  fi
  verbose_log "Fetching forum $fid"
  verbose_debug "Request URL: $url"
  if ! page=$(curl -q --fail --silent --show-error --location --max-redirs 5 \
    --connect-timeout 10 --max-time 40 --proto '=https' --proto-redir '=https' \
    --user-agent "$ua" --cookie - --url "$url" <<< "$cookie_data"); then
    south_error 'Request failed; check the network, HTTP status and proxy settings.'
  fi
  south_check_page "$page"
  printf '%s\n' "$page"
}
