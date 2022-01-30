#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/_base.sh"

export_local_ipv4

if [ ! -e "/sshkey/sshkey" ]; then
  ssh-keygen -t ed25519 -f /sshkey/sshkey -q -N ""
fi
SSH_PUBKEY="$(cat /sshkey/sshkey.pub)"

pushd "$SCRIPT_DIR"/../terraform
terraform apply -auto-approve -var="local_ipv4=$LOCAL_IPV4" -var="ssh_pubkey=$SSH_PUBKEY"
popd

export_server_ip
export_volume_id

echo "Resetting ssh known hosts..."
ssh-keygen -R "$SERVER_IP" || true

echo "Server deployed @ $SERVER_IP"
echo "Waiting for server to be ready..."
until ssh -i /sshkey/sshkey -o "StrictHostKeyChecking no" "root@$SERVER_IP" true >/dev/null 2>&1; do
  echo -n "."
  sleep 1
done
echo ""

cd "$SCRIPT_DIR/../ansible"

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key=/sshkey/sshkey -i "$SERVER_IP," playbook.yaml
