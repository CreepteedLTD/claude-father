#!/bin/zsh
set -e
cd "$(dirname "$0")/.."
REPO="$PWD"
step() { print -P "\n%F{cyan}==>%f $1"; }

step "Claude Code"
command -v claude >/dev/null || { echo "Install Claude Code first: https://claude.com/claude-code"; exit 1; }
ver="${$(claude --version)%% *}"
autoload -Uz is-at-least
if ! is-at-least 2.1.232 "$ver"; then
  echo "Updating Claude Code ($ver → latest, need ≥2.1.232 for cross-session messaging)"
  claude update
fi

step "Dependencies"
if ! command -v tmux >/dev/null; then
  if command -v brew >/dev/null; then brew install tmux
  elif command -v apt-get >/dev/null; then sudo apt-get install -y tmux
  else echo "Install tmux manually, then re-run."; exit 1; fi
fi
export PATH="$HOME/.bun/bin:$PATH"
command -v bun >/dev/null || curl -fsSL https://bun.sh/install | bash

step "Father plugin"
plugins=$(claude plugin list 2>/dev/null)
echo "$plugins" | grep -q 'claude-father@' || {
  claude plugin marketplace add "$REPO" 2>/dev/null || true
  claude plugin install claude-father@claude-father
}

step "Channels"
WANT_TG=n WANT_IM=n
read "a?Set up Telegram? [Y/n] "; [[ "$a" != [Nn]* ]] && WANT_TG=y
if [[ "$OSTYPE" == darwin* ]]; then
  read "a?Set up iMessage? [Y/n] "; [[ "$a" != [Nn]* ]] && WANT_IM=y
fi

if [[ $WANT_TG == y ]]; then
  echo "$plugins" | grep -q 'telegram@claude-plugins-official' || claude plugin install telegram@claude-plugins-official
  TOKEN_FILE="$HOME/.claude/channels/telegram/token"
  if [ ! -f "$TOKEN_FILE" ] && [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "Create a bot: open t.me/BotFather in Telegram → /newbot → copy the token it replies with."
    read "tok?Paste bot token: "
    mkdir -p "${TOKEN_FILE:h}"
    print -r -- "TELEGRAM_BOT_TOKEN=$tok" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
  fi
fi
if [[ $WANT_IM == y ]]; then
  echo "$plugins" | grep -q 'imessage@claude-plugins-official' || claude plugin install imessage@claude-plugins-official
fi

step "Cross-session messaging"
echo "To relay chats to your phone, your sessions must auto-accept messages from"
echo "your OWN other sessions on this machine (otherwise each relay needs a desktop click)."
read "a?Enable that? [Y/n] "
if [[ "$a" != [Nn]* ]]; then
  S="$HOME/.claude/settings.json"
  if [ -f "$S" ]; then
    tmp=$(mktemp) && jq '. + {crossSessionInbound: "accept"}' "$S" > "$tmp" && mv "$tmp" "$S"
  else
    mkdir -p "$HOME/.claude" && echo '{"crossSessionInbound": "accept"}' > "$S"
  fi
fi

step "Launch"
if tmux has-session -t claude-father 2>/dev/null; then
  read "a?A father session is already running — restart it? [y/N] "
  [[ "$a" == [Yy]* ]] && tmux kill-session -t claude-father
fi
read "wd?Working directory for the father [$HOME]: "
"$REPO/scripts/start.sh" -d "${wd:-$HOME}"

step "Done — finish on your phone"
[[ $WANT_TG == y ]] && echo "Telegram: DM your bot → it replies with a code → run: tmux attach -t claude-father, then /telegram:access pair <code>, then /telegram:access policy allowlist"
[[ $WANT_IM == y ]] && echo "iMessage: iMessage yourself; click OK on the 'control Messages' popup after the first reply. If startup complains about Full Disk Access, follow its instructions and re-run this script."
