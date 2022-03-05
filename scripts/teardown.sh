#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/_base.sh"

export_server_ip

echo "Stopping $GAME_DISPLAY_NAME server…"
if [ "$GAME_NAME" = "valheim" ]; then
  ssh -i "/sshkey/sshkey.$GAME_NAME" -o "StrictHostKeyChecking no" "root@$SERVER_IP" "docker kill --signal=SIGINT $GAME_NAME-server && docker wait $GAME_NAME-server"
fi
if [ "$GAME_NAME" = "zomboid" ]; then
  ssh -i "/sshkey/sshkey.$GAME_NAME" -o "StrictHostKeyChecking no" "root@$SERVER_IP" "docker exec $GAME_NAME-server /opt/bin/stop-zomboid.sh && docker wait $GAME_NAME-server"
fi
sleep 5

echo "Backing up gamedata…"
"$SCRIPT_DIR/backup.sh"

echo "Destroying resources…"

cd "$SCRIPT_DIR"/../terraform/"$GAME_NAME"
terraform destroy -auto-approve -var="ssh_pubkey=foobar"

message="$GAME_DISPLAY_NAME server destroyed 🧨💥"
json_message=$(jq -n --arg content "$message" '{$content}')

curl -i \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST \
  --data "$json_message" \
  "$DISCORD_MAIN_CHANNEL_WEBHOOK"
