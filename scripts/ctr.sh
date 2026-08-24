#!/usr/bin/env bash
set -euo pipefail
img="$1"; shift

export TMPDIR="/local/scratch/_jpcourneya/tmp"
export SINGULARITY_TMPDIR="/local/scratch/_jpcourneya/tmp"
export APPTAINER_TMPDIR="/local/scratch/_jpcourneya/tmp"
export SINGULARITY_CACHEDIR="/autofs/scratch/_jpcourneya/nf/apptainer_cache"
export APPTAINER_CACHEDIR="/autofs/scratch/_jpcourneya/nf/apptainer_cache"

"$CTR_BIN" exec --bind "$PWD:$PWD" --pwd "$PWD" "$img" "$@"