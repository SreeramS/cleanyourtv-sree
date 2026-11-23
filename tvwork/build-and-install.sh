#!/usr/bin/env bash
# Rebuild the launcher (after editing its config.xml) and install it on the TV as Home.
# Usage:  ~/SreeProjects/tvwork/build-and-install.sh <TV IP>
# Needs: brew install openjdk@17 android-commandlinetools, and
#        sdkmanager --sdk_root=/opt/homebrew/share/android-commandlinetools "platforms;android-34" "build-tools;34.0.0"
# Config: ~/SreeProjects/cleanyourtv/launcher/app/src/main/res/values/config.xml
set -euo pipefail
TV="${1:?usage: build-and-install.sh <TV IP>}"
cd "$(dirname "$0")/../cleanyourtv"
TV_HOST="$TV" launcher/build-and-install.sh
