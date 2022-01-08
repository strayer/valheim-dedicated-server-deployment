#!/usr/bin/env bash
set -euo pipefail

server_ip="$(cat server_ip.txt)"

echo "Stopping valheim server..."
ssh "root@$server_ip" "systemctl stop valheim"
echo "Looking for world saved in log..."
ssh "root@$server_ip" "journalctl -u valheim -n 200 --no-pager | grep saved" || true
echo "Showing last 3 log lines, should show successful service stopping..."
ssh "root@$server_ip" "journalctl --quiet -u valheim -n 3 --no-pager"
echo "Sleeping 10 seconds... abort if something smells fishy!"
sleep 10
./backup.sh
terraform destroy -target hcloud_server.valheim-server -target cloudflare_record.valheim-server-ipv4 -target cloudflare_record.valheim-server-ipv6 -target hcloud_rdns.valheim-server-ipv4
