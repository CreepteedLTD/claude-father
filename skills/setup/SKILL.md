---
name: setup
description: Set up Claude Father on this machine — install dependencies and channel plugins, configure the Telegram token and required settings, and launch the father session. Use when the user runs /claude-father:setup or asks to install/configure/repair Claude Father.
user-invocable: true
---

# Claude Father setup

Walk the user through a complete, idempotent setup. Check each item and skip what's already done. Report progress as you go, one line per step.

1. **Claude Code version** — needs ≥ 2.1.232 for cross-session messaging and channels. Check `claude --version`; if older, run `claude update` and tell the user existing sessions keep the old version until restarted.
2. **Dependencies** — `tmux` (install via brew/apt if missing) and `bun` (`curl -fsSL https://bun.sh/install | bash` if missing; it lives at `~/.bun/bin`).
3. **Channels** — ask which the user wants: Telegram (any OS) and/or iMessage (macOS only). Install the chosen plugins if not present: `claude plugin install telegram@claude-plugins-official`, `claude plugin install imessage@claude-plugins-official`.
4. **Telegram token** — if Telegram chosen and `~/.claude/channels/telegram/token` doesn't exist: tell the user to open @BotFather in Telegram, send `/newbot`, pick a name and a username ending in `bot`, and paste the token here. Write it as `TELEGRAM_BOT_TOKEN=<token>` to that file, `chmod 600`. If permission rules block writing it, give the user the one-line shell command to run themselves.
5. **Settings** — merge into `~/.claude/settings.json`: `"channelsEnabled": true` (channels are opt-in since 2.1.232) and `"crossSessionInbound": "accept"`. Before setting the second one, explain the trade-off in one sentence: it lets the user's own local sessions message each other without a desktop approval click — required for phone relaying. If a permission gate blocks the edit, tell the user to run `/config`, search "messages", and set "Messages from your other sessions" to accept.
6. **iMessage disk access** — if iMessage chosen: test `sqlite3 ~/Library/Messages/chat.db "select 1"`. On "authorization denied", open `x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles` and tell the user: add your terminal app, toggle on, fully quit and reopen the terminal, then re-run /claude-father:setup. Stop here until done — macOS never shows a prompt for this on its own.
7. **Launch** — run the start skill's procedure (see the `start` skill, or execute `scripts/start.sh` from this plugin's root) with the user's chosen working directory.
8. **Hand off** — final message: Telegram: "DM your bot; it replies a pairing code; give it to me or run /telegram:access pair <code> in the father session, then /telegram:access policy allowlist." iMessage: "iMessage yourself; click OK on the 'control Messages' popup after the first reply." Suggest the optional BotFather `/setcommands` menu (chats / status / back) from the README.
