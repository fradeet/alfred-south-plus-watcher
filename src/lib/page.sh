south_error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

south_check_page() {
  local page=$1 title login challenge
  [[ -s $page ]] || south_error 'The HTML input is empty.'
  title=$(htmlq --filename "$page" --text title)
  login=$(htmlq --filename "$page" --attribute name 'form[name="login"]')
  challenge=$(htmlq --filename "$page" --attribute id '#challenge-form, #cf-challenge-running, #cf-wrapper')
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
