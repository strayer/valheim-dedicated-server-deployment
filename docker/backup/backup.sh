#!/usr/bin/env bash
set -euo pipefail

cd "$GAMEDATA_PATH"
restic backup -H "$GAME_NAME" --tag "$BACKUP_TAG" --no-cache -v .
