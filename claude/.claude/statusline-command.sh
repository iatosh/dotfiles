#!/bin/bash
# Claude Code statusLine command
# Prints: dir, a color-coded context usage bar, and the 5h rate limit
# with time-to-reset shown via an hourglass icon whose fill reflects how
# much of the window is left (full -> half -> empty).

input=$(cat)

# Current directory with ~ substitution
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$dir" ] && dir=$(pwd)
dir="${dir/#$HOME/~}"

# p10k-style path shortening: components collapse to their first character
# (dotfile dirs keep the dot plus one char, so .config reads as .c), but only
# as many as needed — shortening walks left to right and stops as soon as the
# path fits DIR_MAX_LEN. The current directory is never touched, and neither
# are components of DIR_KEEP_LEN chars or fewer, since abbreviating those
# saves almost nothing.
DIR_MAX_LEN=20
DIR_KEEP_LEN=4
shorten_dir() {
  p=$1
  [ "${#p}" -le "$DIR_MAX_LEN" ] && { printf '%s' "$p"; return; }
  case "$p" in
    /*) lead="/"; rest="${p#/}" ;;
    *)  lead="";  rest="$p" ;;
  esac
  IFS='/' read -r -a parts <<< "$rest"
  n=${#parts[@]}
  join_parts() { local IFS='/'; printf '%s%s' "$lead" "${parts[*]}"; }
  i=0
  while [ "$i" -lt $((n - 1)) ]; do
    cur=$(join_parts)
    [ "${#cur}" -le "$DIR_MAX_LEN" ] && break
    seg="${parts[$i]}"
    if [ "${#seg}" -gt "$DIR_KEEP_LEN" ]; then
      case "$seg" in
        .?*) parts[$i]="${seg:0:2}" ;;
        *)   parts[$i]="${seg:0:1}" ;;
      esac
    fi
    i=$((i+1))
  done
  join_parts
}
dir=$(shorten_dir "$dir")

ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')

FIVE_HOUR_SECS=18000

# Real escape bytes, so later plain string concatenation doesn't need
# reinterpreting (only printf's own format arg parses "\033" as an escape).
RESET=$(printf '\033[00m')
DIM=$(printf '\033[02m')
TRACK=$(printf '\033[38;5;238m')
DIRCOLOR=$(printf '\033[34m')
DIRCOLOR_BOLD=$(printf '\033[01;34m')

# Continuous truecolor gradient green -> yellow -> red, saturating to
# pure red by 90 (rather than only at 100) so high usage reads as urgent
# well before the gauge is technically full.
cont_color() {
  p=$(printf '%.0f' "$1")
  [ "$p" -lt 0 ] && p=0
  [ "$p" -gt 100 ] && p=100
  if [ "$p" -ge 90 ]; then
    r=220; g=60; b=60
  elif [ "$p" -le 45 ]; then
    t=$(( p * 100 / 45 ))
    r=$(( 46 + (230-46) * t / 100 ))
    g=$(( 204 + (200-204) * t / 100 ))
    b=$(( 64 + (40-64) * t / 100 ))
  else
    t=$(( (p - 45) * 100 / 45 ))
    r=$(( 230 + (220-230) * t / 100 ))
    g=$(( 200 + (60-200) * t / 100 ))
    b=$(( 40 + (60-40) * t / 100 ))
  fi
  printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# Braille gauge, whole cells only (ceil, so 1% already lights one ⣿).
# The whole filled run shares a single color from the current value via
# cont_color; unfilled cells stay a dim gray track so the full width is
# always visible.
bar() {
  val=$(printf '%.0f' "$1")
  width=16
  filled=$(( (val * width + 99) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  color=$(cont_color "$val")
  out="${color}"
  i=0; while [ "$i" -lt "$filled" ]; do out="${out}⣿"; i=$((i+1)); done
  out="${out}${RESET}${TRACK}"
  i=0; while [ "$i" -lt $((width - filled)) ]; do out="${out}⣿"; i=$((i+1)); done
  out="${out}${RESET}"
  printf '%s' "$out"
}

# Hourglass icon reflecting fraction of the 5h window still remaining
hourglass_icon() {
  remain=$1
  pct_left=$(( remain * 100 / FIVE_HOUR_SECS ))
  if   [ "$pct_left" -gt 80 ]; then printf ''   # hourglass_start (full)
  elif [ "$pct_left" -gt 20 ]; then printf ''   # hourglass_half
  else                              printf ''   # hourglass_end (empty)
  fi
}

# Effort level -> braille fill glyph, same dot family as the context/rate
# bars so it reads as one visual language.
effort_icon() {
  case "$1" in
    low)    printf '⣀' ;;
    medium) printf '⣄' ;;
    high)   printf '⣦' ;;
    xhigh)  printf '⣶' ;;
    max)    printf '⣿' ;;
  esac
}
# Seconds until epoch -> "Xh Ym" (or "Ym" under an hour)
fmt_remaining() {
  now=$(date +%s)
  remain=$(( $1 - now ))
  [ "$remain" -lt 0 ] && remain=0
  h=$(( remain / 3600 ))
  m=$(( (remain % 3600) / 60 ))
  if [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
  else printf '%dm' "$m"
  fi
}

# Context usage: gauge + percentage
ctx_seg=""
if [ -n "$ctx" ]; then
  ctx_seg="$(bar "$ctx") $(cont_color "$ctx")$(printf '%.0f' "$ctx")%${RESET}"
fi

# 5h rate limit: percentage + hourglass + time-to-reset, in brackets
limit_seg=""
if [ -n "$five" ]; then
  seg="${DIM}[${RESET}$(cont_color "$five")$(printf '%.0f' "$five")%${RESET}"
  if [ -n "$five_reset" ]; then
    now=$(date +%s)
    remain=$(( five_reset - now ))
    [ "$remain" -lt 0 ] && remain=0
    icon=$(hourglass_icon "$remain")
    seg="${seg} ${DIM}${icon} $(fmt_remaining "$five_reset")${RESET}"
  fi
  seg="${seg}${DIM}]${RESET}"
  limit_seg="$seg"
fi

# Model name + effort. Dim throughout (no gradient color) so it never
# competes with the saturated context/rate-limit bars elsewhere on the line
# — the glyph's fill step alone carries the level. No effort field (model
# doesn't support it) -> no icon, just the plain model name.
model_seg=""
if [ -n "$model" ]; then
  if [ -n "$effort" ]; then
    model_seg="${DIM}$(effort_icon "$effort") ${model}${RESET}"
  else
    model_seg="${DIM}${model}${RESET}"
  fi
fi

# Split off the last path component so it can be bolded on its own,
# with the rest of the path in regular weight.
if [ "$dir" != "${dir%/*}" ]; then
  dir_parent="${dir%/*}/"
  dir_base="${dir##*/}"
else
  dir_parent=""
  dir_base="$dir"
fi

# Line 1: directory (parent dim, current component bold), then the 5h rate limit
line1="${DIRCOLOR}${dir_parent}${RESET}${DIRCOLOR_BOLD}${dir_base}${RESET}"
[ -n "$limit_seg" ] && line1="${line1} ${limit_seg}"

# Line 2: model name, then context usage gauge
line2="$model_seg"
if [ -n "$ctx_seg" ]; then
  [ -n "$line2" ] && line2="${line2} ${ctx_seg}" || line2="$ctx_seg"
fi

printf '%s\n%s' "$line1" "$line2"
