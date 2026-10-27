south_error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

south_base_url() {
  local base=${SOUTH_BASE_URL:-https://spring-plus.net/}
  [[ $base =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/[^[:space:]?#]*)?$ ]] ||
    south_error 'SOUTH_BASE_URL must be an HTTP(S) base URL without credentials, whitespace, query or fragment.'
  printf '%s/\n' "${base%/}"
}

south_check_page() {
  local page=$1 title login challenge
  [[ -n $page ]] || south_error 'The HTML input is empty.'
  title=$(htmlq --text title <<< "$page")
  login=$(htmlq --attribute name 'form[name="login"]' <<< "$page")
  challenge=$(htmlq --attribute id '#challenge-form, #cf-challenge-running, #cf-wrapper' <<< "$page")
  case "${title,,}" in
    *'just a moment'*|*'attention required'*|*'access denied'*)
      south_error 'The site returned an access challenge or denial page.' ;;
  esac
  [[ -z $challenge ]] || south_error 'The site returned a Cloudflare challenge page.'
  [[ -z $login ]] || south_error 'Login is required or the Cookie has expired.'
  case "$title" in
    *只有注册会员*|*没有权限*|*无权访问*) south_error 'The account cannot access this page.' ;;
  esac
  [[ -n $title ]] || south_error 'Expected an HTML page with a title.'
}
