#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TERRAFORM_PATH=$SCRIPT_DIR/../terraform

function export_local_ipv4() {
	export LOCAL_IPV4
	LOCAL_IPV4="$(curl -s4 https://icanhazip.com)"
}

function export_volume_id() {
  export HCLOUD_VOLUME_ID;
	pushd "$TERRAFORM_PATH"
	HCLOUD_VOLUME_ID="$("terraform" output -raw volume_id)"
	popd
}

function export_server_ip() {
	export SERVER_IP
	pushd "$TERRAFORM_PATH"
	SERVER_IP="$("terraform" output -raw server_ip)"
	popd
}
