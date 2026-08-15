---
name: setup
description: Set up Claude Father on this machine — install dependencies and channel plugins, configure the Telegram token and required settings, and launch Claude Father session. Use when the user runs /claude-father:setup or asks to install/configure/repair Claude Father.
user-invocable: true
---

# Claude Father setup

Walk the user through a complete, idempotent setup. Check each item and skip what's already done. Report progress as you go, one line per step.

1. **Claude Code version** — needs ≥ 2.1.232 for cross-session messaging and channels. Check `claude --version`; if older, run `claude update` and tell the user existing sessions keep the old version until restarted.
2. **Dependencies** — `tmux` (install via brew/apt if missing) and `bun` (`curl -fsSL https://bun.sh/install | bash` if missing; it lives at `~/.bun/bin`).
3. **Channels** — ask which the user wants: Telegram (any OS, built into this plugin — nothing to install; if `telegram@claude-plugins-official` is installed, disable it with `claude plugin disable telegram@claude-plugins-official` so two bridges never fight over the bot) and/or iMessage (macOS only: `claude plugin install imessage@claude-plugins-official`).
4. **Telegram token** — if Telegram chosen and `~/.claude/channels/telegram/token` doesn't exist: tell the user to open @BotFather in Telegram, send `/newbot`, pick a name and a username ending in `bot`, and paste the token here. Write it as `TELEGRAM_BOT_TOKEN=<token>` to that file, `chmod 600`. If permission rules block writing it, give the user the one-line shell command to run themselves. Also set `"ackReaction": "👀"` in `~/.claude/channels/telegram/access.json` so every received message gets an instant 👀 receipt before any processing.
5. **Settings** — nothing to edit: the launcher passes `channelsEnabled` and `crossSessionInbound` per-session via the `--settings` flag, so `~/.claude/settings.json` is never touched. One optional tip for the user: running `/config` → search "messages" → set "Messages from your other sessions" to accept lets chats they open *manually* also be relayed to the phone without a desktop approval click; sessions Claude Father spawns don't need it.
6. **iMessage disk access** — if iMessage chosen: test `sqlite3 ~/Library/Messages/chat.db "select 1"`. On "authorization denied", open `x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles` and tell the user: add your terminal app, toggle on, fully quit and reopen the terminal, then re-run /claude-father:setup. Stop here until done — macOS never shows a prompt for this on its own.
7. **Launch** — run the start skill's procedure (see the `start` skill, or execute `scripts/start.sh` from this plugin's root) with the user's chosen working directory.
   - **Org-policy check**: ~20s after launch, run `tmux capture-pane -t claude-father -p` and look for "blocked by org policy". This happens on org-managed accounts (claude.ai Team/Enterprise), where channels are admin-gated and user/session settings cannot override. If found, give the user these options and stop until resolved:
     1. Machine-admin fix (works unless the org pushes server-side managed settings):
        ```sh
        sudo mkdir -p "/Library/Application Support/ClaudeCode"
        echo '{"channelsEnabled": true}' | sudo tee "/Library/Application Support/ClaudeCode/managed-settings.json"
        ```
        (Linux: `/etc/claude-code/managed-settings.json`.) Then `tmux kill-session -t claude-father` and relaunch.
     2. Ask an org admin to enable channels for the org in claude.ai admin settings → Claude Code.
     3. Log this machine into a personal (Pro/Max) account instead of the org account.
8. **Hand off** — final message: Telegram: "DM your bot; it replies a pairing code; give it to me or run /claude-father:access pair <code> in Claude Father session, then /claude-father:access policy allowlist." iMessage: "iMessage yourself; click OK on the 'control Messages' popup after the first reply." Suggest the optional BotFather `/setcommands` menu (chats / status / back) from the README.
