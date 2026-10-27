south_check_page() {
  local page=$1 title login challenge
  [[ -n $page ]] || { printf '%s\n' 'The HTML input is empty.'; return 1; }
  title=$(htmlq --text title <<< "$page") || { printf '%s\n' 'Unable to read the page title.'; return 1; }
  login=$(htmlq --attribute name 'form[name="login"]' <<< "$page") || { printf '%s\n' 'Unable to check the login form.'; return 1; }
  challenge=$(htmlq --attribute id '#challenge-form, #cf-challenge-running, #cf-wrapper' <<< "$page") || { printf '%s\n' 'Unable to check the challenge page.'; return 1; }
  case "${title,,}" in
    *'just a moment'*|*'attention required'*|*'access denied'*)
      printf '%s\n' 'The site returned an access challenge or denial page.'; return 1 ;;
  esac
  [[ -z $challenge ]] || { printf '%s\n' 'The site returned a Cloudflare challenge page.'; return 1; }
  [[ -z $login ]] || { printf '%s\n' 'Login is required or the Cookie has expired.'; return 1; }
  case "$title" in
    *只有注册会员*|*没有权限*|*无权访问*) printf '%s\n' 'The account cannot access this page.'; return 1 ;;
  esac
  [[ -n $title ]] || { printf '%s\n' 'Expected an HTML page with a title.'; return 1; }
}
