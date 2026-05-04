#!/usr/bin/env bash
# Notifies you via macOS notification when Claude usage becomes available again.
# Run once to install; it will auto-start at login and clean up after itself.
#
# Usage: ./wait_for_claude.sh
# Uninstall: ./wait_for_claude.sh --uninstall

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
LABEL="com.$(whoami).claude-usage-poller"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOGFILE="$HOME/.claude/usage_poller.log"
INTERVAL=300  # seconds between checks

uninstall() {
  launchctl unload "$PLIST" 2>/dev/null
  rm -f "$PLIST"
  echo "Uninstalled."
}

install() {
  mkdir -p "$HOME/.claude"
  cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
        <string>--poll</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>$LOGFILE</string>
    <key>StandardErrorPath</key>
    <string>$LOGFILE</string>
</dict>
</plist>
EOF
  launchctl load "$PLIST"
  echo "Installed. You'll receive a macOS notification when Claude usage resets."
}

poll() {
  echo "[$(date)] Poller started." >> "$LOGFILE"
  while true; do
    OUTPUT=$(claude -p "ping" --output-format text 2>&1)
    STATUS=$?
    if [ $STATUS -eq 0 ]; then
      echo "[$(date)] Claude is available — sending notification." >> "$LOGFILE"
      osascript -e 'display notification "Your Claude usage has reset — you'\''re good to go!" with title "Claude" sound name "Ping"'
      launchctl unload "$PLIST" 2>/dev/null
      rm -f "$PLIST"
      echo "[$(date)] LaunchAgent removed. Poller done." >> "$LOGFILE"
      exit 0
    else
      echo "[$(date)] Not yet available (exit $STATUS). Retrying in ${INTERVAL}s." >> "$LOGFILE"
      sleep "$INTERVAL"
    fi
  done
}

case "$1" in
  --poll)     poll ;;
  --uninstall) uninstall ;;
  *)
    if [ -f "$PLIST" ]; then
      echo "Already installed. Run with --uninstall to remove."
    else
      install
    fi
    ;;
esac
