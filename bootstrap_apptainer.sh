mkdir -p /autofs/scratch/_jpcourneya/nf/apptainer_cache
mkdir -p /autofs/scratch/_jpcourneya/ampliconSeq/containers
mkdir -p /local/scratch/_jpcourneya/tmp

export TMPDIR=/local/scratch/_jpcourneya/tmp
export APPTAINER_TMPDIR=/local/scratch/_jpcourneya/tmp
export APPTAINER_CACHEDIR=/autofs/scratch/_jpcourneya/nf/apptainer_cache

# If apptainer not in PATH, use singularity binary directly:
CTR_BIN=$(command -v apptainer || echo /usr/local/packages/singularity/bin/singularity)

$CTR_BIN --version