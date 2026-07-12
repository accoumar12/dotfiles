#!/usr/bin/env bash
# Install & load the Karabiner VHID + kanata LaunchDaemons. Run with: sudo bash install_kanata_daemons.sh
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="/Library/LaunchDaemons"

for plist in com.karabiner.vhid-daemon.plist com.kanata.plist; do
  cp "$SRC/$plist" "$DEST/$plist"
  chown root:wheel "$DEST/$plist"
  chmod 644 "$DEST/$plist"
  # reload cleanly if already loaded
  launchctl bootout "system/${plist%.plist}" 2>/dev/null || true
  launchctl bootstrap system "$DEST/$plist"
  echo "loaded $plist"
done

echo "done — check: sudo launchctl print system/com.kanata"
