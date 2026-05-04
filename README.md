# wait-for-claude

Get a native macOS notification when your [Claude](https://claude.ai) usage resets after being exhausted.

## Requirements

- macOS
- [Claude Code CLI](https://claude.ai/code) installed and on your PATH

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/rach-gold/wait-for-claude/main/wait_for_claude.sh -o wait_for_claude.sh && chmod +x wait_for_claude.sh && ./wait_for_claude.sh
```

This installs a LaunchAgent that:
- Runs in the background and survives restarts
- Checks every 5 minutes if Claude is available
- Sends a macOS notification with sound when usage resets
- Cleans up after itself automatically

## Uninstall

```sh
./wait_for_claude.sh --uninstall
```

## How it works

The script polls the Claude CLI every 5 minutes. When it gets a successful response, it fires a native macOS notification and removes itself.
