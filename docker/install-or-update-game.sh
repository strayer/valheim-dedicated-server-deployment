#!/usr/bin/env bash
set -euo pipefail

echo "--> Installing game"

mkdir -p "$GAME_PATH"

"$STEAMCMD_PATH/steamcmd.sh" +force_install_dir "$GAME_PATH" +login anonymous +app_update "$STEAMAPPID" +quit
