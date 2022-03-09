#!/usr/bin/env bash
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/_base.sh"

export_server_ip

ssh -i "/sshkey/sshkey.$GAME_NAME" -o "StrictHostKeyChecking no" "root@$SERVER_IP" "docker run --rm --read-only -v /gamedata:/gamedata --env-file /env-backup --tmpfs /tmp --add-host \$(cat /restic-host) -e BACKUP_TAG=after-session ghcr.io/strayer/game-server-deployment-discord-bot/backup:latest backup.sh"

mkdir -p "$BACKUP_PATH/$GAME_NAME/current"

cd "$BACKUP_PATH/$GAME_NAME"
rsync --delete -avP --no-o --no-g -e "ssh -i /sshkey/sshkey.$GAME_NAME -o \"StrictHostKeyChecking no\"" "root@$SERVER_IP:/gamedata/" current/

sleep 10

cd current
tar cjf "../backup_$(date +"%FT%H%M").tar.bz2" --exclude='*/.fuse_hidden*' -- *
