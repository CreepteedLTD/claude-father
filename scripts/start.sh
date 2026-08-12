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

if [[ "$CHANNELS" == *imessage* && "$OSTYPE" == darwin* ]]; then
  if ! sqlite3 "$HOME/Library/Messages/chat.db" "select 1" >/dev/null 2>&1; then
    case "$TERM_PROGRAM" in
      Apple_Terminal) APP="Terminal";;
      iTerm.app) APP="iTerm";;
      *) APP="${TERM_PROGRAM:-the app this terminal runs in}";;
    esac
    echo "The iMessage channel needs Full Disk Access, and macOS won't prompt for it."
    echo "Opening System Settings → Privacy & Security → Full Disk Access now."
    echo
    echo "  1. Click '+', add '$APP', and turn its toggle ON"
    echo "  2. Quit $APP completely (Cmd-Q) and reopen it"
    echo "  3. Run this script again"
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    exit 1
  fi
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
  "claude 'Invoke the claude-father skill and follow it as your operating instructions for this session.'$FLAGS"
echo "$SESSION started in $DIR (channels: $CHANNELS)."
echo "Attach with: tmux attach -t $SESSION"
