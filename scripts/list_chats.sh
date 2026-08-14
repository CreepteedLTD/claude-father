#!/bin/bash
# usage: list_chats.sh [N]  — N latest chats across all projects, freshest first
N="${1:-15}"

live_ids=$(cat "$HOME"/.claude/sessions/*.json 2>/dev/null | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4 | sort -u)

ls -t "$HOME"/.claude/projects/*/*.jsonl 2>/dev/null | head -"$N" | while read -r f; do
  id=$(basename "$f" .jsonl)
  ts=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null || stat -c '%y' "$f" | cut -c1-16)
  title=$(grep -o '"aiTitle":"[^"]*"' "$f" | tail -1 | cut -d'"' -f4)
  dir=$(grep -m1 -o '"cwd":"[^"]*"' "$f" | cut -d'"' -f4)
  if echo "$live_ids" | grep -q "^$id$"; then state="LIVE"; else state="off "; fi
  echo "$ts | $state | ${title:-<untitled>} | $id | $dir"
done
