#!/bin/sh
# Claude Code statusLine command
# Reads JSON from stdin once, prints: abbreviated path + context % + rate limits

input=$(cat)

# Current directory with ~ substitution
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')
if [ -z "$dir" ]; then
  dir=$(pwd)
fi
dir="${dir/#$HOME/~}"

# Context window used percentage
ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# 5-hour rate limit used percentage
five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# 7-day rate limit used percentage
week=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Color only the number in "label:N%": green <50, yellow <80, red >=80
color_pct() {
  label="$1"
  val=$(printf '%.0f' "$2")
  if [ "$val" -ge 80 ]; then
    color='\033[31m'   # red
  elif [ "$val" -ge 50 ]; then
    color='\033[33m'   # yellow
  else
    color='\033[32m'   # green
  fi
  printf "\033[02m%s:\033[00m${color}%d%%\033[00m" "$label" "$val"
}

# Build rate/context suffix
suffix=""
if [ -n "$ctx" ]; then
  suffix=$(color_pct "ctx" "$ctx")
fi
if [ -n "$five" ]; then
  [ -n "$suffix" ] && suffix="$suffix "
  suffix="${suffix}$(color_pct "5h" "$five")"
fi
if [ -n "$week" ]; then
  [ -n "$suffix" ] && suffix="$suffix "
  suffix="${suffix}$(color_pct "7d" "$week")"
fi

# Print: blue path, then suffix if present
if [ -n "$suffix" ]; then
  printf '\033[01;34m%s\033[00m \033[02m[\033[00m%s\033[02m]\033[00m' "$dir" "$suffix"
else
  printf '\033[01;34m%s\033[00m' "$dir"
fi

