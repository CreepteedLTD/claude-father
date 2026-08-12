# claude-father

One always-on Claude Code session ("father") you control from **Telegram** and/or **iMessage**. From one chat you can:

- start multiple tasks that run in parallel on your machine
- get status of everything that's running
- see and message your other open Claude Code sessions
- spawn new sessions (tmux windows or headless) for bigger tasks

Built entirely on official Claude Code features: [channels](https://code.claude.com/docs/en/channels) (Telegram/iMessage plugins), cross-session messaging (ListAgents/SendMessage), and background agents. This plugin just adds the orchestrator skill + a launcher.

## Prerequisites

- macOS or Linux (iMessage channel: macOS only)
- Claude Code **≥ 2.1.224** (`claude update`)
- `tmux` (`brew install tmux`)
- [Bun](https://bun.sh) — the channel servers run on it: `curl -fsSL https://bun.sh/install | bash`

## Install

```sh
git clone https://github.com/pashaverdi/claude-father.git
claude plugin marketplace add ./claude-father
claude plugin install claude-father@claude-father
```

Then install at least one channel:

```sh
claude plugin install telegram@claude-plugins-official
claude plugin install imessage@claude-plugins-official   # macOS only
```

## Channel setup (once per machine)

### Telegram

1. In Telegram, message [@BotFather](https://t.me/BotFather) → `/newbot` → pick a name and a username ending in `bot`. Copy the token (`123456789:AAH...`).
2. In any `claude` session: `/telegram:configure <token>`
3. Start the father (below), then DM your bot — it replies with a 6-character pairing code.
4. In the father session: `/telegram:access pair <code>`
5. Lock it to your account: `/telegram:access policy allowlist`

### iMessage (macOS)

1. Grant your terminal **Full Disk Access** (System Settings → Privacy & Security) — macOS prompts on first run.
2. Start the father (below), then iMessage **yourself** — self-chat works immediately, no pairing.
3. First outbound reply triggers an Automation prompt ("control Messages") — click OK.
4. Optionally allow other people: `/imessage:access allow +15551234567`

## Run

```sh
./claude-father/scripts/start.sh -d ~/work        # -d = directory the father works from
```

Flags: `-d workdir` (default: current dir), `-c telegram,imessage` (default: every installed channel plugin), `-s tmux-session-name` (default: `claude-father`).

The script starts (or re-attaches to) a detached tmux session running `claude` with the channels enabled and the orchestrator skill as its instructions. Attach any time with `tmux attach -t claude-father`; detach with `Ctrl-b d`.

## Use

Message your bot (or yourself on iMessage):

- "run the tests in project X and fix failures" → spawns a background task
- "status" → summary of everything running
- "tell the session working on the parser to also update the docs" → relays to that session

## Limits

- The father cannot answer **permission prompts** in spawned sessions — it will tell you which tmux window to attach to.
- Cross-session messages are plain text; the father steers other sessions by messaging them, not by driving their tools.
- The father must stay running (the tmux session) for chat to reach it.
