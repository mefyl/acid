#!/usr/bin/env bash

set -euo pipefail

NIX_DIR="$(dirname "$0")"

echo "source_env $NIX_DIR/.envrc" >> .envrc
direnv allow
