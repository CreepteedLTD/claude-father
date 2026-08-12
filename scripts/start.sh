#!/bin/zsh
# usage: start.sh [-d workdir] [-c telegram,imessage,discord] [-s tmux-session-name]
set -e

DIR="$PWD"
CHANNELS=""
SESSION="claude-father"
while getopts "d:c:s:" opt; do
  case $opt in
    d) DIR="$OPTARG";;
    c) CHANNELS="$OPTARG";;
    s) SESSION="$OPTARG";;
    *) exit 1;;
  esac
done

export PATH="$HOME/.bun/bin:$PATH"

for cmd in claude tmux; do
  command -v "$cmd" >/dev/null || { echo "$cmd not found — see README prerequisites"; exit 1; }
done

if [ -z "$CHANNELS" ]; then
  installed=$(claude plugin list 2>/dev/null)
  for ch in telegram imessage discord; do
    if echo "$installed" | grep -q "$ch@claude-plugins-official"; then
      CHANNELS="$CHANNELS,$ch"
    fi
  done
  CHANNELS="${CHANNELS#,}"
fi

if [ -z "$CHANNELS" ]; then
  echo "No channel plugins installed. Install at least one:"
  echo "  claude plugin install telegram@claude-plugins-official"
  echo "  claude plugin install imessage@claude-plugins-official"
  exit 1
fi

FLAGS=""
for ch in ${(s:,:)CHANNELS}; do
  FLAGS="$FLAGS --channels plugin:$ch@claude-plugins-official"
done

if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

mkdir -p "$HOME/.claude/father"
tmux new-session -d -s "$SESSION" -c "$DIR" \
  "claude$FLAGS 'Invoke the claude-father skill and follow it as your operating instructions for this session.'"
echo "$SESSION started in $DIR (channels: $CHANNELS)."
echo "Attach with: tmux attach -t $SESSION"
