#!/usr/bin/env bash
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/_base.sh"

export_server_ip
export_volume_id

mkdir -p "$BACKUP_PATH/current"

cd "$BACKUP_PATH"
rsync --delete -avP -e "ssh -i /sshkey/sshkey -o \"StrictHostKeyChecking no\"" "root@$SERVER_IP:/mnt/HC_Volume_${HCLOUD_VOLUME_ID}/valheim-home/.config/unity3d/IronGate/Valheim/" current/
cd current
tar cjf "../backup_$(date +"%FT%H%M").tar.bz2" -- *
