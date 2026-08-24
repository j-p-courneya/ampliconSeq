#!/usr/bin/env bash
set -euo pipefail
img="$1"; shift
# shellcheck disable=SC1091
source config/containers.env

"$CTR_BIN" exec --bind "$PWD:$PWD" --pwd "$PWD" "$img" "$@"