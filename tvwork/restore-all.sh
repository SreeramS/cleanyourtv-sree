#!/usr/bin/env bash
# Put the BRAVIA VU2 back the way it was on 2026-11-17, before the cleanup.
# Usage (from anywhere):  ~/SreeProjects/tvwork/restore-all.sh <TV IP>
# Needs USB debugging switched on again on the TV (Settings > System > Developer options).
set -euo pipefail
TV="${1:?usage: restore-all.sh <TV IP>}"
cd "$(dirname "$0")/../cleanyourtv"
export TV_HOST="$TV"
PY=tools/venv/bin/python
L=../tvwork/lists
# Newest batch first. Batch 4 also gives Home back to the stock Google TV launcher.
tools/restore.sh "$L/4-after-launcher.txt" com.google.android.tvlauncher
tools/restore.sh "$L/3-unused-streaming.txt"
tools/restore.sh "$L/2-unused-system.txt"
tools/restore.sh "$L/1-telemetry.txt"
# Settings changed outside the lists, back to what backup/ recorded:
"$PY" -I tools/tv.py 'settings put secure screensaver_components com.google.android.backdrop/com.google.android.backdrop.Backdrop'
"$PY" -I tools/tv.py 'settings put global private_dns_mode opportunistic'
"$PY" -I tools/tv.py 'settings delete global private_dns_specifier'
echo "Restored. To remove the new launcher as well: $PY -I tools/tv.py 'pm uninstall com.gathin.tvhome'"
