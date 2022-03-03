#!/usr/bin/env bash
set -euo pipefail

echo "--> Installing steamcmd"

if [ -e "$STEAMCMD_PATH/steamcmd.sh" ]; then
  echo "--> steamcmd already installed, exiting."
  exit
fi

mkdir -p "$STEAMCMD_PATH"
cd "$STEAMCMD_PATH"

curl -LO https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
  tar xf steamcmd_linux.tar.gz && \
  chmod +x steamcmd.sh && \
  chmod +x linux32/steamcmd && \
  rm steamcmd_linux.tar.gz
