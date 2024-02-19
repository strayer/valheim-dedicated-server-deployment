#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/_base.sh"

export_terraform_data_dir

if [ ! -e "/sshkey/sshkey.$GAME_NAME" ]; then
  ssh-keygen -t ed25519 -f /sshkey/sshkey."$GAME_NAME" -q -N ""
fi
SSH_PUBKEY="$(cat /sshkey/sshkey."$GAME_NAME".pub)"

pushd "$SCRIPT_DIR"/../terraform/"$GAME_NAME"
terraform apply -auto-approve -var="ssh_pubkey=$SSH_PUBKEY" \
  -var="game_persona_bot_name=$BOT_GAME_PERSONA_NAME" \
  -var="game_persona_bot_avatar_url=$BOT_GAME_PERSONA_AVATAR_URL" \
  -var="bot_server_started_message=$BOT_MESSAGE_SERVER_STARTED" \
  -var="bot_server_ready_message=$BOT_MESSAGE_SERVER_READY"
popd

export_server_ip

echo "Resetting ssh known hosts..."
ssh-keygen -R "$SERVER_IP" || true

echo "Server deployed @ $SERVER_IP"
