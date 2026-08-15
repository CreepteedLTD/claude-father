#!/bin/bash
# usage: topics.sh create <chat_id> <name>       → prints new topic id
#        topics.sh rename <chat_id> <topic_id> <name>
#        topics.sh close  <chat_id> <topic_id>
#        topics.sh send   <chat_id> <topic_id> <text>
set -e
TOKEN="${TELEGRAM_BOT_TOKEN:-$(cut -d= -f2 "$HOME/.claude/channels/telegram/token" 2>/dev/null)}"
[ -n "$TOKEN" ] || { echo "no bot token" >&2; exit 1; }
API="https://api.telegram.org/bot$TOKEN"

case "$1" in
  create)
    curl -sf "$API/createForumTopic" -d chat_id="$2" --data-urlencode name="$3" | grep -o '"message_thread_id":[0-9]*' | cut -d: -f2 ;;
  rename)
    curl -sf "$API/editForumTopic" -d chat_id="$2" -d message_thread_id="$3" --data-urlencode name="$4" >/dev/null && echo ok ;;
  close)
    curl -sf "$API/closeForumTopic" -d chat_id="$2" -d message_thread_id="$3" >/dev/null && echo ok ;;
  send)
    curl -sf "$API/sendMessage" -d chat_id="$2" -d message_thread_id="$3" --data-urlencode text="$4" | grep -o '"message_id":[0-9]*' | head -1 | cut -d: -f2 ;;
  *)
    echo "usage: topics.sh create|rename|close|send ..." >&2; exit 1 ;;
esac
