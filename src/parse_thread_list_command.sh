local page id tid cell title date url marker type level
page=$(cat)

while IFS= read -r id; do
  tid=${id#a_ajax_}
  cell="td#td_$tid"
  title=$(htmlq --text "$cell h3 a#$id" <<< "$page")
  date=$(htmlq --text "$cell + td > div.f10.gray2" <<< "$page")
  url=$(htmlq --base "${args[--base-url]}" --attribute href "$cell h3 a#$id" <<< "$page")
  marker=$(htmlq --attribute src "$cell img[title=\"置顶帖标志\"]" <<< "$page")
  type=normal
  level=null
  if [[ $marker =~ headtopic_([0-9]+)\. ]]; then
    type=pinned
    level=${BASH_REMATCH[1]}
  fi
  jq -cn --arg title "$title" --arg date "$date" --arg url "$url" \
    --arg type "$type" --argjson level "$level" '
    def trim: gsub("^\\s+|\\s+$"; "");
    {title: ($title | trim), published_date: ($date | trim),
     thread_type: $type, pin_level: $level, url: ($url | trim)}
  '
done < <(htmlq --attribute id 'tr.tr3 a[id^="a_ajax_"]' <<< "$page") |
  jq -sr --arg format "${args[--output-format]}" '
    if $format == "json" then .
    else .[] | [.title, .published_date, .thread_type, .pin_level, .url] | @tsv
    end
  '
