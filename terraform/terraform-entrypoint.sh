#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat >/terraform/terraform.rc <<EOL
credentials "app.terraform.io" {
  token = "${TERRAFORM_CLOUD_TOKEN}"
}
EOL

(
  cd "$SCRIPT_DIR/../terraform"
  terraform init -lockfile=readonly
);

exec "$@"
