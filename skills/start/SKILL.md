---
name: start
description: Launch or re-attach the Claude Father orchestrator tmux session with messaging channels enabled. Use when the user runs /claude-father:start or asks to start/restart the father.
user-invocable: true
---

# Start Claude Father

Run `scripts/start.sh` from this plugin's root directory, passing `-d <workdir>` (ask the user which directory the father should work from if not obvious; default `$HOME`). The script re-attaches if a `claude-father` tmux session already exists, auto-detects installed channel plugins, exports the Telegram token, checks iMessage disk access, and launches a detached tmux session.

To restart (e.g. after a Claude Code update): `tmux kill-session -t claude-father`, then run the script again. Warn the user first if the father has child windows with running work (`tmux list-windows -t claude-father`).

After starting, verify within ~30s that the channel bridge came up: a `bun run` process for each chosen channel should exist, and `~/Library/Caches/claude-cli-nodejs/<cwd-slug>/mcp-logs-plugin-telegram-telegram/` (or `...-imessage-imessage/`) should have a fresh log. If not, check `channelsEnabled: true` is in `~/.claude/settings.json` and the session's Claude version is ≥ 2.1.232.
