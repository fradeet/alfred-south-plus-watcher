(
  set -eEuo pipefail
  trap 'printf "Error: Unable to parse the thread list.\n" >&2' ERR
  base=$(south_base_url)
  umask 077
  work=$(mktemp -d)
  trap 'rm -rf -- "$work"' EXIT
  cat > "$work/page.html"
  south_check_page "$work/page.html"
  table=$(htmlq -f "$work/page.html" --attribute id 'table#ajaxtable')
  [[ $table == ajaxtable ]] || south_error 'No PHPWind thread-list table was found.'
  htmlq -f "$work/page.html" --attribute id '#ajaxtable tr.tr3 a[id^="a_ajax_"]' > "$work/ids"
  htmlq -f "$work/page.html" --attribute href '#ajaxtable tr.tr3 h3 a[href*="read.php?"]' > "$work/links"
  id_count=$(jq -Rs 'split("\n") | map(select(length > 0)) | length' "$work/ids")
  link_count=$(jq -Rs 'split("\n") | map(select(length > 0)) | length' "$work/links")
  [[ $id_count == "$link_count" ]] || south_error 'Some thread titles are missing their expected IDs.'
  jq -Rse 'split("\n") | map(select(length > 0)) | length == (unique | length)' \
    "$work/ids" >/dev/null || south_error 'Duplicate thread IDs were found.'
  : > "$work/threads.jsonl"
  while IFS= read -r id; do
    [[ $id =~ ^a_ajax_([0-9]+)$ ]] || south_error 'Invalid thread ID.'
    tid=${BASH_REMATCH[1]}
    cell="#ajaxtable td#td_$tid"
    title=$(htmlq -f "$work/page.html" --text "$cell h3 a#$id")
    date=$(htmlq -f "$work/page.html" --text "$cell + td > div.f10.gray2")
    url=$(htmlq -f "$work/page.html" --base "$base" --attribute href "$cell h3 a#$id")
    marker=$(htmlq -f "$work/page.html" --attribute src "$cell img[title=\"置顶帖标志\"]")
    type=normal
    level=null
    if [[ -n $marker ]]; then
      [[ $marker =~ headtopic_([0-9]+)\. ]] || south_error "Invalid pin marker for thread $tid."
      type=pinned
      level=$((10#${BASH_REMATCH[1]}))
    fi
    jq -cen --arg title "$title" --arg date "$date" --arg url "$url" \
      --arg type "$type" --argjson level "$level" '
      def trim: gsub("^\\s+|\\s+$"; "");
      def valid_date:
        if test("^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$") then
          split("-") | map(tonumber) | .[0] as $y | .[1] as $m | .[2] as $d |
          ($y % 400 == 0 or ($y % 4 == 0 and $y % 100 != 0)) as $leap |
          $y > 0 and $d <= ([31, (if $leap then 29 else 28 end), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][$m - 1])
        else false end;
      {title: ($title | trim), published_date: ($date | trim),
       thread_type: $type, pin_level: $level, url: ($url | trim)} |
      select(.title != "" and
        (.published_date | valid_date) and
        (.url | test("^https?://[^\\s]+$")))
    ' >> "$work/threads.jsonl" || south_error "Missing or invalid fields for thread $tid."
  done < "$work/ids"
  # Distinguish an empty list from a changed layout.
  if [[ ! -s $work/ids ]]; then
    links=$(htmlq -f "$work/page.html" --attribute href '#ajaxtable tr.tr3 a[href*="read.php?"]')
    [[ -z $links ]] || south_error 'Thread links were found without the expected title IDs.'
    header=$(htmlq -f "$work/page.html" --text '#ajaxtable tr.tr2')
    [[ $header == *文章* && $header == *作者* ]] || south_error 'Unrecognized thread-list layout.'
  fi
  jq -csr --arg format "${args[--output-format]}" '
    if $format == "alfred_json" then {alfredworkflow: {arg: map(.url + "\t" + .title)}}
    elif $format == "json" then .
    else .[] | [.title, .published_date, .thread_type, .pin_level, .url] | @tsv
    end
  ' "$work/threads.jsonl" > "$work/result"
  cat "$work/result"
)
