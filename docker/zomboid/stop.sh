#!/usr/bin/env bash
set -euo pipefail

screen -S zomboid -p 0 -X stuff "quit^M"
