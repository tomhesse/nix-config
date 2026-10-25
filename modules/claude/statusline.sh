# shellcheck shell=bash
#
# Renders Claude Code's status line from the session JSON on stdin.
#
# Colours are the 16 standard ANSI codes rather than literal hex, so the line
# follows the terminal's own palette -- kitty is themed by catppuccin, which
# makes this track the flavour without hardcoding it or depending on the
# palette derivation.

payload=$(cat)

# Set CLAUDE_STATUSLINE_DEBUG=1 to capture the raw payload for inspection.
if [[ -n ${CLAUDE_STATUSLINE_DEBUG:-} ]]; then
  printf '%s\n' "$payload" >>"${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline.jsonl"
fi

# One jq call, one field per line, read with mapfile rather than `read`: tab and
# newline are IFS whitespace, so a `read` split collapses runs of them and every
# field after an absent one shifts left. mapfile ignores IFS and keeps empty
# lines, so missing fields stay in place. Each field below is positional -- keep
# the jq list and the assignments in step.
mapfile -t fields < <(
  printf '%s' "$payload" | jq -r '
    [ .workspace.project_dir // .cwd // ""
    , .cwd // ""
    , (.workspace.added_dirs // [] | length)
    , .model.display_name // ""
    , (.fast_mode // false)
    , (.context_window.remaining_percentage // "")
    , (.rate_limits.five_hour.used_percentage // "")
    , (.cost.total_lines_added // 0)
    , (.cost.total_lines_removed // 0)
    , .worktree.name // ""
    , (.exceeds_200k_tokens // false)
    , .agent.name // ""
    , .session_name // ""
    ] | map(tostring) | .[]' 2>/dev/null
)

project_dir=${fields[0]:-}
cwd=${fields[1]:-}
added_dirs=${fields[2]:-0}
model=${fields[3]:-}
fast_mode=${fields[4]:-false}
context_left=${fields[5]:-}
five_hour=${fields[6]:-}
lines_added=${fields[7]:-0}
lines_removed=${fields[8]:-0}
worktree=${fields[9]:-}
exceeds_200k=${fields[10]:-false}
agent_name=${fields[11]:-}
session_name=${fields[12]:-}

reset=$'\033[0m'
dim=$'\033[2m'
bold=$'\033[1m'
red=$'\033[31m'
green=$'\033[32m'
yellow=$'\033[33m'
blue=$'\033[34m'
magenta=$'\033[35m'
cyan=$'\033[36m'

segments=()

# Project directory, with the subpath when Claude's cwd sits below it.
label=${project_dir##*/}
if [[ -n $cwd && $cwd != "$project_dir" ]]; then
  case $cwd in
    "$project_dir"/*) label="$label/${cwd#"$project_dir"/}" ;;
    *) label=${cwd##*/} ;;
  esac
fi
if [[ $added_dirs -gt 0 ]]; then
  label="$label ${dim}+${added_dirs}"
fi
if [[ -n $label ]]; then
  segments+=("${blue} ${bold}${label}${reset}")
fi

# Branch, dirty marker, and the worktree name when inside one.
if [[ -n $cwd ]] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null); then
  dirty=""
  if [[ -n $(git -C "$cwd" --no-optional-locks status --porcelain -uno 2>/dev/null) ]]; then
    dirty="${yellow}*"
  fi
  if [[ -n $worktree ]]; then
    segments+=("${cyan}wt:${worktree}${reset}")
  fi
  segments+=("${magenta} ${branch}${dirty}${reset}")
fi

# Model, with a bolt when fast mode is on.
if [[ -n $model ]]; then
  bolt=""
  if [[ $fast_mode == "true" ]]; then
    bolt=" ${yellow}"
  fi
  segments+=("${cyan}${model}${bolt}${reset}")
fi

# The agent the session itself is running as. Subagents spawned during the
# session run on their own threads and do not show up here.
if [[ -n $agent_name ]]; then
  segments+=("${blue}agent:${agent_name}${reset}")
fi

# Context remaining: the number that decides whether to compact.
if [[ -n $context_left ]]; then
  printf -v left '%.0f' "$context_left"
  if [[ $left -gt 50 ]]; then
    colour=$green
  elif [[ $left -ge 20 ]]; then
    colour=$yellow
  else
    colour="${red}${bold}"
  fi
  segments+=("${colour}ctx ${left}%${reset}")
fi

# Past 200k the session is priced differently. The percentage above does not
# show this on its own, because a 1M context window is measured against 1M.
if [[ $exceeds_200k == "true" ]]; then
  segments+=("${yellow}200k+${reset}")
fi

# Five hour rate limit window, quiet until it starts to matter. Populated from
# rate limit response headers, so it is absent until the first reply lands.
if [[ -n $five_hour ]]; then
  printf -v used '%.0f' "$five_hour"
  if [[ $used -gt 85 ]]; then
    segments+=("${red}${bold}5h ${used}%${reset}")
  elif [[ $used -gt 60 ]]; then
    segments+=("${yellow}5h ${used}%${reset}")
  fi
fi


# Diff churn for the session.
if [[ $lines_added -gt 0 || $lines_removed -gt 0 ]]; then
  segments+=("${green}+${lines_added}${dim}/${reset}${red}-${lines_removed}${reset}")
fi

line=""
for segment in "${segments[@]}"; do
  if [[ -n $line ]]; then
    line+="${dim} · ${reset}"
  fi
  line+=$segment
done

# Length in characters, ignoring the ANSI sequences, which occupy no columns.
visible_width() {
  local text=$1 plain=""
  while [[ $text == *$'\033['* ]]; do
    plain+=${text%%$'\033['*}
    text=${text#*$'\033['}
    text=${text#*m}
  done
  printf '%s' "$(( ${#plain} + ${#text} ))"
}

# Session title, pushed to the right margin. Claude Code passes COLUMNS to the
# command, and trims the finished line -- which strips trailing whitespace but
# not interior, so the padding before the title survives. Without a width, or
# without room for it, the title is dropped rather than crowding the chips.
if [[ -n $session_name && ${COLUMNS:-0} -gt 0 ]]; then
  title=$session_name
  if [[ ${#title} -gt 40 ]]; then
    title="${title:0:39}..."
  fi
  pad=$(( COLUMNS - $(visible_width "$line") - ${#title} ))
  if [[ $pad -ge 2 ]]; then
    printf -v spaces '%*s' "$pad" ''
    line+="${spaces}${dim}${title}${reset}"
  fi
fi

printf '%s' "$line"
