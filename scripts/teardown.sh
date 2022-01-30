#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/_base.sh"

export_server_ip

echo "Stopping valheim server…"
ssh -i "/sshkey/sshkey" -o "StrictHostKeyChecking no" "root@$SERVER_IP" "systemctl stop valheim"
sleep 5

echo "Backing up world…"
"$SCRIPT_DIR/backup.sh"

echo "Destroying resources…"

cd "$SCRIPT_DIR"/../terraform
terraform destroy -auto-approve \
  -target hcloud_server.valheim-server \
  -target cloudflare_record.valheim-server-ipv4 \
  -target cloudflare_record.valheim-server-ipv6 \
  -target hcloud_rdns.valheim-server-ipv4 \
  -var="local_ipv4=1.1.1.1" \
  -var="ssh_pubkey=foobar"

message="Valheim server destroyed 🧨💥"
json_message=$(jq -n --arg content "$message" '{$content}')

curl -i \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST \
  --data "$json_message" \
  "$DISCORD_MAIN_CHANNEL_WEBHOOK"
