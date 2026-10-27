south_parse_forum() {
  local page=$1 base table ids links issue threads id tid cell title date url marker type level thread header result
  base=$(south_base_url) || { printf '%s\n' "$base"; return 1; }
  verbose_log "Parsing forum threads"
  table=$(htmlq --attribute id 'table#ajaxtable' <<< "$page") || { printf '%s\n' 'Unable to read the thread-list table.'; return 1; }
  [[ $table == ajaxtable ]] || { printf '%s\n' 'No PHPWind thread-list table was found.'; return 1; }
  ids=$(htmlq --attribute id '#ajaxtable tr.tr3 a[id^="a_ajax_"]' <<< "$page") || { printf '%s\n' 'Unable to read thread IDs.'; return 1; }
  links=$(htmlq --attribute href '#ajaxtable tr.tr3 h3 a[href*="read.php?"]' <<< "$page") || { printf '%s\n' 'Unable to read thread links.'; return 1; }
  issue=$(jq -nr --arg ids "$ids" --arg links "$links" '
    def lines: split("\n") | map(select(length > 0));
    ($ids | lines) as $ids | ($links | lines) as $links |
    if ($ids | length) != ($links | length) then "Some thread titles are missing their expected IDs."
    elif ($ids | length) != ($ids | unique | length) then "Duplicate thread IDs were found."
    else empty end
  ') || { printf '%s\n' 'Unable to validate thread IDs and links.'; return 1; }
  [[ -z $issue ]] || { printf '%s\n' "$issue"; return 1; }
  threads=
  while IFS= read -r id; do
    [[ -n $id ]] || continue
    [[ $id =~ ^a_ajax_([0-9]+)$ ]] || { printf '%s\n' 'Invalid thread ID.'; return 1; }
    tid=${BASH_REMATCH[1]}
    cell="#ajaxtable td#td_$tid"
    title=$(htmlq --text "$cell h3 a#$id" <<< "$page") || { printf '%s\n' "Unable to read the title for thread $tid."; return 1; }
    date=$(htmlq --text "$cell + td > div.f10.gray2" <<< "$page") || { printf '%s\n' "Unable to read the date for thread $tid."; return 1; }
    url=$(htmlq --base "$base" --attribute href "$cell h3 a#$id" <<< "$page") || { printf '%s\n' "Unable to read the URL for thread $tid."; return 1; }
    marker=$(htmlq --attribute src "$cell img[title=\"置顶帖标志\"]" <<< "$page") || { printf '%s\n' "Unable to read the pin marker for thread $tid."; return 1; }
    type=normal
    level=null
    if [[ -n $marker ]]; then
      [[ $marker =~ headtopic_([0-9]+)\. ]] || { printf '%s\n' "Invalid pin marker for thread $tid."; return 1; }
      type=pinned
      level=$((10#${BASH_REMATCH[1]}))
    fi
    thread=$(jq -cen --arg title "$title" --arg date "$date" --arg url "$url" \
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
    ') || { printf '%s\n' "Missing or invalid fields for thread $tid."; return 1; }
    threads+="$thread"$'\n'
  done <<< "$ids"
  # Distinguish an empty list from a changed layout.
  if [[ -z $ids ]]; then
    links=$(htmlq --attribute href '#ajaxtable tr.tr3 a[href*="read.php?"]' <<< "$page") || { printf '%s\n' 'Unable to read thread links.'; return 1; }
    [[ -z $links ]] || { printf '%s\n' 'Thread links were found without the expected title IDs.'; return 1; }
    header=$(htmlq --text '#ajaxtable tr.tr2' <<< "$page") || { printf '%s\n' 'Unable to read the thread-list header.'; return 1; }
    [[ $header == *文章* && $header == *作者* ]] || { printf '%s\n' 'Unrecognized thread-list layout.'; return 1; }
  fi
  result=$(jq -cs '{alfredworkflow: {arg: map(.url + "\t" + .title),
    variables: {success: true, error_msg: ""}}}' <<< "$threads") || { printf '%s\n' 'Unable to format forum results.'; return 1; }
  printf '%s\n' "$result"
}
