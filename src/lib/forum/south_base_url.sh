south_base_url() {
  local base=${SP_BASE_URL}
  [[ $base =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/[^[:space:]?#]*)?$ ]] ||
    south_error 'SP_BASE_URL must be an HTTP(S) base URL without credentials, whitespace, query or fragment.'
  printf '%s/\n' "${base%/}"
}
