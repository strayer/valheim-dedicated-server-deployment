#!/usr/bin/env bash
set -euo pipefail

restic restore latest -H "$GAME_NAME" --no-cache -v --target "$GAMEDATA_PATH"
