south_parse_forum() {
  local page=$1 base table ids links issue threads id tid cell title date url marker type level thread header
  base=$(south_base_url)
  verbose_log "Parsing forum threads"
  table=$(htmlq --attribute id 'table#ajaxtable' <<< "$page")
  [[ $table == ajaxtable ]] || south_error 'No PHPWind thread-list table was found.'
  ids=$(htmlq --attribute id '#ajaxtable tr.tr3 a[id^="a_ajax_"]' <<< "$page")
  links=$(htmlq --attribute href '#ajaxtable tr.tr3 h3 a[href*="read.php?"]' <<< "$page")
  issue=$(jq -nr --arg ids "$ids" --arg links "$links" '
    def lines: split("\n") | map(select(length > 0));
    ($ids | lines) as $ids | ($links | lines) as $links |
    if ($ids | length) != ($links | length) then "Some thread titles are missing their expected IDs."
    elif ($ids | length) != ($ids | unique | length) then "Duplicate thread IDs were found."
    else empty end
  ')
  [[ -z $issue ]] || south_error "$issue"
  threads=
  while IFS= read -r id; do
    [[ -n $id ]] || continue
    [[ $id =~ ^a_ajax_([0-9]+)$ ]] || south_error 'Invalid thread ID.'
    tid=${BASH_REMATCH[1]}
    cell="#ajaxtable td#td_$tid"
    title=$(htmlq --text "$cell h3 a#$id" <<< "$page")
    date=$(htmlq --text "$cell + td > div.f10.gray2" <<< "$page")
    url=$(htmlq --base "$base" --attribute href "$cell h3 a#$id" <<< "$page")
    marker=$(htmlq --attribute src "$cell img[title=\"置顶帖标志\"]" <<< "$page")
    type=normal
    level=null
    if [[ -n $marker ]]; then
      [[ $marker =~ headtopic_([0-9]+)\. ]] || south_error "Invalid pin marker for thread $tid."
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
    ') || south_error "Missing or invalid fields for thread $tid."
    threads+="$thread"$'\n'
  done <<< "$ids"
  # Distinguish an empty list from a changed layout.
  if [[ -z $ids ]]; then
    links=$(htmlq --attribute href '#ajaxtable tr.tr3 a[href*="read.php?"]' <<< "$page")
    [[ -z $links ]] || south_error 'Thread links were found without the expected title IDs.'
    header=$(htmlq --text '#ajaxtable tr.tr2' <<< "$page")
    [[ $header == *文章* && $header == *作者* ]] || south_error 'Unrecognized thread-list layout.'
  fi
  jq -cs '{alfredworkflow: {arg: map(.url + "\t" + .title)}}' <<< "$threads"
}
