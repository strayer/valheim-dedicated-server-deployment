#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for game in valheim; do
  (
    cd "$SCRIPT_DIR/../terraform/$game"
    terraform init -lockfile=readonly -backend-config="bucket=$TERRAFORM_BACKEND_BUCKET"
  );
done

exec "$@"
