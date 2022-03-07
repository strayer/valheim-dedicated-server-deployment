#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TERRAFORM_PATH=$SCRIPT_DIR/../terraform/"$GAME_NAME"

function export_server_ip() {
	export SERVER_IP
	pushd "$TERRAFORM_PATH"
	SERVER_IP="$("terraform" output -raw server_ip)"
	popd
}

function export_terraform_data_dir() {
  export TF_DATA_DIR="$TF_DATA_DIR_BASE"/"$GAME_NAME"

  mkdir -p "$TF_DATA_DIR"
}
