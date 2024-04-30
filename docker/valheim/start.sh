#!/usr/bin/env bash
set -euo pipefail

export LD_LIBRARY_PATH=/opt/valheim/linux64:${LD_LIBRARY_PATH:-}

cd /opt/valheim

exec /opt/valheim/valheim_server.x86_64 -nographics -batchmode -name "$VALHEIM_SERVER_NAME" -port 2456 -world "$VALHEIM_SERVER_WORLD" -password "$VALHEIM_SERVER_PASSWORD" -public 0
