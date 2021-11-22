#!/usr/bin/env bash
set -xeuo pipefail

server_ip="$(cat server_ip.txt)"

mkdir -p backup/current

cd backup
rsync --delete -avP "root@${server_ip}:/mnt/HC_Volume_${HCLOUD_VOLUME_ID}/valheim-home/.config/unity3d/IronGate/Valheim/" current/
cd current
tar cjf "../backup_$(date +"%FT%H%M").tar.bz2" -- *
