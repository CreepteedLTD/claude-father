#!/bin/bash
# Guards Claude Father's ownership of the Telegram bot connection.
# Every 2 min: the poller recorded in bot.pid must be alive and be the
# father's own (launched with TELEGRAM_FORCE_POLL). Otherwise respawn
# the father, whose poller reclaims the slot.
DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION="${1:-claude-father}"
WORKDIR="${2:-$HOME}"
PID_FILE="$HOME/.claude/channels/telegram/bot.pid"

while true; do
  sleep 120
  tmux has-session -t "$SESSION" 2>/dev/null || exit 0
  pid=$(cat "$PID_FILE" 2>/dev/null)
  ok=""
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    ps -p "$pid" -o command= | grep -q server.ts && \
      ps eww "$pid" 2>/dev/null | grep -q TELEGRAM_FORCE_POLL && ok=1
  fi
  if [ -z "$ok" ]; then
    echo "$(date '+%F %T') poller lost (pid=$pid) — respawning Claude Father" >> "$HOME/.claude/father/watchdog.log"
    "$DIR/start.sh" -r -d "$WORKDIR" -s "$SESSION" >/dev/null 2>&1
    sleep 60
  fi
done
