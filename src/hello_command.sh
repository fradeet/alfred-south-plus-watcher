verbose_log 'Generating Alfred result'
result=$(jq -cn '{items: [{title: "Hello Alfred", subtitle: "Bashly + Alfred", valid: false}]}')
verbose_debug "Hello result: $result"
printf '%s\n' "$result"
