#!/usr/bin/env bash
set -euo pipefail

echo "--> Updating steamcmd"

"$STEAMCMD_PATH/steamcmd.sh" +quit
