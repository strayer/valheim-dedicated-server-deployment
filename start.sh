#!/usr/bin/env bash
set -euo pipefail

terraform apply

server_ip="$(cat server_ip.txt)"

echo "Resetting ssh known hosts..."
ssh-keygen -R "$server_ip"

echo "Server deployed @ $server_ip"
echo "Waiting for server to be ready..."
until ssh -o "StrictHostKeyChecking no" "root@${server_ip}" true >/dev/null 2>&1; do
  echo -n "."
  sleep 1
done
echo ""

ansible-playbook -i inventory playbook.yaml
