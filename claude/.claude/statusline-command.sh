#!/bin/sh
# Claude Code statusLine command
# Prints: dir, a color-coded context usage bar, and the 5h rate limit
# with time-to-reset shown via an hourglass icon whose fill reflects how
# much of the window is left (full -> half -> empty).

input=$(cat)

# Current directory with ~ substitution
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$dir" ] && dir=$(pwd)
dir="${dir/#$HOME/~}"

ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

FIVE_HOUR_SECS=18000

# Real escape bytes, so later plain string concatenation doesn't need
# reinterpreting (only printf's own format arg parses "\033" as an escape).
RESET=$(printf '\033[00m')
DIM=$(printf '\033[02m')
TRACK=$(printf '\033[38;5;238m')

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

suffix=""

# Context usage: gauge + percentage
if [ -n "$ctx" ]; then
  suffix="$(bar "$ctx") $(cont_color "$ctx")$(printf '%.0f' "$ctx")%${RESET}"
fi

# 5h rate limit: percentage + hourglass + time-to-reset, in brackets
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
  [ -n "$suffix" ] && suffix="$suffix "
  suffix="${suffix}${seg}"
fi

if [ -n "$suffix" ]; then
  printf '\033[01;34m%s\033[00m %s' "$dir" "$suffix"
else
  printf '\033[01;34m%s\033[00m' "$dir"
fi
