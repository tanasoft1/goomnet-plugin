#!/usr/bin/env bash
# SessionStart hook: bridge the plugin's userConfig into the CLI's .env.
#
# Claude Code exports userConfig values only to hook processes
# (CLAUDE_PLUGIN_OPTION_<KEY>), not to the Bash tool where the CLI runs.
# This hook writes them to $GOOMNET_HOME/.env (chmod 600) so the CLI can read
# them. It stays silent when everything is in order; anything it prints on
# stdout is added to Claude's context, so it only speaks when setup is needed.

set -euo pipefail

D="${GOOMNET_HOME:-$HOME/.claude/goomnet}"
ENV_FILE="$D/.env"
TOKEN_FILE="$D/.token"

url="${GOOMNET_URL:-https://goomnet.tanasoft.mn}"
email="${CLAUDE_PLUGIN_OPTION_EMAIL:-}"
password="${CLAUDE_PLUGIN_OPTION_PASSWORD:-}"

missing=()
for bin in curl jq; do command -v "$bin" >/dev/null 2>&1 || missing+=("$bin"); done
if [ ${#missing[@]} -gt 0 ]; then
  echo "goomnet plugin: the goomnet CLI needs ${missing[*]}, which is not installed. Tell the user to install it (macOS: brew install ${missing[*]}) before using goomnet."
fi

if [ -n "$email" ] && [ -n "$password" ]; then
  # %q keeps passwords with quotes, spaces or $ intact when the CLI sources the file.
  new=$(printf '# written by the goomnet plugin from its userConfig; change via /plugin configure goomnet@tanasoft, not by hand\nGOOMNET_URL=%q\nGOOMNET_EMAIL=%q\nGOOMNET_PASSWORD=%q\n' \
          "$url" "$email" "$password")
  if [ ! -f "$ENV_FILE" ] || [ "$(cat "$ENV_FILE")" != "$new" ]; then
    mkdir -p "$D"; chmod 700 "$D"
    ( umask 077; printf '%s\n' "$new" > "$ENV_FILE" )
    rm -f "$TOKEN_FILE"   # credentials changed: drop the cached token for the old account
  fi
elif [ ! -f "$ENV_FILE" ]; then
  echo "goomnet plugin: installed but not configured. If the user asks about goomnet, tell them to run /plugin configure goomnet@tanasoft in Claude Code, enter their goomnet email and password, then start a new session."
fi
