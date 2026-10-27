south_base_url() {
  local base=${SP_BASE_URL}
  [[ $base =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/[^[:space:]?#]*)?$ ]] ||
    { printf '%s\n' 'SP_BASE_URL must be an HTTP(S) base URL without credentials, whitespace, query or fragment.'; return 1; }
  printf '%s/\n' "${base%/}"
}
