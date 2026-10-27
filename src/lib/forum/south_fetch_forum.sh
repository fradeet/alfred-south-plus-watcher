south_fetch_forum() {
  local fid=$1 base url host ua cookie_data page
  [[ $fid =~ ^[0-9]+$ ]] || { printf '%s\n' 'Subforum ID must contain only digits.'; return 1; }
  base=$(south_base_url) || { printf '%s\n' "$base"; return 1; }
  url=${base}thread.php?fid-${fid}.html
  [[ $url =~ ^https://([a-zA-Z0-9.-]+)(:[0-9]+)?(/[^[:space:]]*)?$ ]] ||
    { printf '%s\n' 'Use an HTTPS URL without credentials or whitespace.'; return 1; }
  host=${BASH_REMATCH[1]}
  ua=${SP_USER_AGENT:-'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'}
  [[ $ua != *$'\r'* && $ua != *$'\n'* ]] || { printf '%s\n' 'User-Agent must be a single line.'; return 1; }
  if [[ -n ${SP_COOKIE_FILE:-} ]]; then
    [[ -f $SP_COOKIE_FILE && -r $SP_COOKIE_FILE && -s $SP_COOKIE_FILE ]] ||
      { printf '%s\n' 'SP_COOKIE_FILE must be a readable, non-empty file.'; return 1; }
    cookie_data=$(< "$SP_COOKIE_FILE")
  else
    [[ -n ${SP_WINDUSER:-} ]] || { printf '%s\n' 'Set SP_WINDUSER or SP_COOKIE_FILE.'; return 1; }
    [[ $SP_WINDUSER != *[[:space:]]* && $SP_WINDUSER != *';'* ]] ||
      { printf '%s\n' 'SP_WINDUSER must contain only the Cookie value.'; return 1; }
    # Scope the Cookie to the requested host and pass it through stdin.
    printf -v cookie_data '# Netscape HTTP Cookie File\n%s\tFALSE\t/\tTRUE\t0\teb9e6_winduser\t%s\n' \
      "$host" "$SP_WINDUSER"
  fi
  verbose_log "Fetching forum $fid"
  verbose_debug "Request URL: $url"
  if ! page=$(curl -q --fail --silent --show-error --location --max-redirs 5 \
    --connect-timeout 10 --max-time 40 --proto '=https' --proto-redir '=https' \
    --user-agent "$ua" --cookie - --url "$url" <<< "$cookie_data"); then
    printf '%s\n' 'Request failed; check the network, HTTP status and proxy settings.'
    return 1
  fi
  south_check_page "$page" || return 1
  printf '%s\n' "$page"
}
