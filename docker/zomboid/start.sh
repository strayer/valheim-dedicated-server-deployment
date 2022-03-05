#!/usr/bin/env bash
set -euo pipefail

/opt/bin/notify-discord-server-starting.sh || true

export LD_LIBRARY_PATH="${GAME_PATH}/jre64/lib:${LD_LIBRARY_PATH:-}"

cd "$GAME_PATH"

screen -L -Logfile /tmp/zomboid.log -DmS zomboid ./start-server.sh -servername "$ZOMBOID_SERVERNAME" -adminpassword "$ZOMBOID_ADMINPASSWORD" -steamvac false &
PID=$!
echo "$PID" > /run/zomboid.pid

until [ -e /tmp/zomboid.log ]; do
  sleep 1
done

# instantly flush screen logfile
screen -r zomboid -p0 -X logfile flush 0

tail -f -n +1 /tmp/zomboid.log &

wait $PID
