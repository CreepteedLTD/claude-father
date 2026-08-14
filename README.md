# Claude Father

One always-on Claude Code session ("father") you control from **Telegram** and/or **iMessage**. From one chat you can:

- start multiple tasks that run in parallel on your machine
- get status of everything that's running
- list your chats by freshness — live and dormant — and revive any of them
- focus on one chat and keep working with it from your phone, then switch to another
- spawn new sessions (tmux windows or headless) for bigger tasks

Built entirely on official Claude Code features: [channels](https://code.claude.com/docs/en/channels) (Telegram/iMessage plugins), cross-session messaging (ListAgents/SendMessage), and background agents. This plugin adds the orchestrator skill, a chat-listing script, and a launcher.

## Install

```sh
git clone https://github.com/CreepteedLTD/claude-father.git
./claude-father/scripts/setup.sh
```

That's it. The script installs anything missing (tmux, Bun, the channel plugins), asks which channels you want, prompts for your Telegram bot token, checks macOS Full Disk Access for iMessage, enables cross-session messaging, and launches the father. The only steps it can't do for you:

- **Telegram**: create the bot yourself — [@BotFather](https://t.me/BotFather) → `/newbot` → paste the token when the script asks. After launch, DM the bot once and approve the pairing code it gives you (`/telegram:access pair <code>` in the father session), then `/telegram:access policy allowlist`.
- **iMessage (macOS)**: if Full Disk Access is missing, the script opens the right System Settings pane — add your terminal, reopen it, re-run. After launch, iMessage yourself and click OK on the one "control Messages" popup.

Re-running `setup.sh` is safe — it skips whatever is already done.

## Run / restart later

```sh
./claude-father/scripts/start.sh -d ~/work        # -d = directory the father works from
```

Flags: `-d workdir` (default: current dir), `-c telegram,imessage` (default: every installed channel plugin), `-s tmux-session-name` (default: `claude-father`).

Starts (or re-attaches to) a detached tmux session. Attach any time with `tmux attach -t claude-father`; detach with `Ctrl-b d`.

## Use — message your bot (or yourself on iMessage)

- `/chats` (or "show my latest chats") → numbered, freshness-sorted list of your chats, live and dormant
- reply with just a number → switch to that chat, reviving it with full context if it's offline
- while focused, every message you send relays to that chat (a 👀 reaction confirms the forward; the answer comes back as the only reply)
- `/back` (or "back to you") → stop relaying, talk to the father again
- `/status` → summary of everything running
- "run the tests in project X and fix failures" → spawns a background task
- "tell the session working on the parser to also update the docs" → one-off relay

**Telegram menu (optional, recommended):** in [@BotFather](https://t.me/BotFather) run `/setcommands`, pick your bot, paste:

```
chats - List my latest chats (reply a number to switch)
status - What's running right now
back - Stop relaying, talk to the father
```

The ☰ menu button then appears in the bot chat — tap `/chats`, type a digit, and you've switched sessions.

## Limits

- The father cannot answer **permission prompts** in spawned sessions — it tells you which tmux window to attach to.
- Cross-session messages are plain text; the father steers other sessions by messaging them, not by driving their tools.
- The father must stay running (the tmux session) for chat to reach it.
- "Enable cross-session messaging" in setup sets `crossSessionInbound: "accept"` — your sessions auto-deliver messages from your *own* other local sessions without a desktop approval click. Decline it if you prefer approving each relay manually.

## Manual setup (reference)

Everything `setup.sh` automates, if you'd rather do it by hand: Claude Code ≥ 2.1.232 (`claude update`); `brew install tmux`; `curl -fsSL https://bun.sh/install | bash`; `claude plugin marketplace add ./claude-father && claude plugin install claude-father@claude-father`; `claude plugin install telegram@claude-plugins-official` and/or `imessage@claude-plugins-official`; Telegram token into `~/.claude/channels/telegram/token` as `TELEGRAM_BOT_TOKEN=<token>` (or `/telegram:configure <token>` in a session); `/config` → "Messages from your other sessions" → accept; then `scripts/start.sh`.
