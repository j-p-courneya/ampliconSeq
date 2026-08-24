#!/usr/bin/env bash
set -euo pipefail

# ---------- Config ----------
CTR_BIN="${CTR_BIN:-$(command -v apptainer || echo /usr/local/packages/singularity/bin/singularity)}"
CONTAINERS_DIR="${CONTAINERS_DIR:-containers}"

export TMPDIR="${TMPDIR:-/local/scratch/_jpcourneya/tmp}"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$TMPDIR}"
export SINGULARITY_TMPDIR="${SINGULARITY_TMPDIR:-$TMPDIR}"
export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-/autofs/scratch/_jpcourneya/nf/apptainer_cache}"
export SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR:-$APPTAINER_CACHEDIR}"

mkdir -p "$CONTAINERS_DIR" "$TMPDIR" "$APPTAINER_CACHEDIR" config

# ---------- Helpers ----------
pull_if_missing() {
  local sif="$1"
  local uri="$2"
  if [[ -s "$sif" ]]; then
    echo "[INFO] exists: $sif"
  else
    echo "[INFO] pulling: $uri"
    "$CTR_BIN" pull "$sif" "$uri"
  fi
}

validate_cmd() {
  local label="$1"
  shift
  echo "[INFO] validate: $label"
  "$@"
}

# ---------- Exact pinned images ----------
CUTADAPT_TAG="4.9--py310h1fe012e_3"
BWA_TAG="0.7.17--he4a0461_11"
SAMTOOLS_TAG="1.21--h50ea8bc_0"
BEDTOOLS_TAG="2.31.1--hf5e1c6e_2"
GATK4_TAG="4.1.9.0--py36hdfd78af_1"
VCFTOOLS_TAG="0.1.16--pl5321h077b44d_12"

CUTADAPT_SIF="${CONTAINERS_DIR}/cutadapt_4.9.sif"
BWA_SIF="${CONTAINERS_DIR}/bwa_0.7.17.sif"
SAMTOOLS_SIF="${CONTAINERS_DIR}/samtools_1.21.sif"
BEDTOOLS_SIF="${CONTAINERS_DIR}/bedtools_2.31.1.sif"
GATK4_SIF="${CONTAINERS_DIR}/gatk4_4.1.9.0.sif"
VCFTOOLS_SIF="${CONTAINERS_DIR}/vcftools_0.1.16.sif"

pull_if_missing "$CUTADAPT_SIF" "docker://quay.io/biocontainers/cutadapt:${CUTADAPT_TAG}"
pull_if_missing "$BWA_SIF"      "docker://quay.io/biocontainers/bwa:${BWA_TAG}"
pull_if_missing "$SAMTOOLS_SIF" "docker://quay.io/biocontainers/samtools:${SAMTOOLS_TAG}"
pull_if_missing "$BEDTOOLS_SIF" "docker://quay.io/biocontainers/bedtools:${BEDTOOLS_TAG}"
pull_if_missing "$GATK4_SIF"    "docker://quay.io/biocontainers/gatk4:${GATK4_TAG}"
pull_if_missing "$VCFTOOLS_SIF" "docker://quay.io/biocontainers/vcftools:${VCFTOOLS_TAG}"

echo
echo "[INFO] validating tool versions..."
validate_cmd "cutadapt" "$CTR_BIN" exec "$CUTADAPT_SIF" cutadapt --version
validate_cmd "bwa"      bash -c "\"$CTR_BIN\" exec \"$BWA_SIF\" bwa 2>&1 | head -n 3"
validate_cmd "samtools" bash -c "\"$CTR_BIN\" exec \"$SAMTOOLS_SIF\" samtools --version | head -n 2"
validate_cmd "bedtools" "$CTR_BIN" exec "$BEDTOOLS_SIF" bedtools --version
validate_cmd "gatk4"    "$CTR_BIN" exec "$GATK4_SIF" gatk --version
validate_cmd "vcftools" "$CTR_BIN" exec "$VCFTOOLS_SIF" vcftools --version

cat > config/containers.env <<EOF
CTR_BIN=${CTR_BIN}

export TMPDIR=${TMPDIR}
export APPTAINER_TMPDIR=${APPTAINER_TMPDIR}
export SINGULARITY_TMPDIR=${SINGULARITY_TMPDIR}
export APPTAINER_CACHEDIR=${APPTAINER_CACHEDIR}
export SINGULARITY_CACHEDIR=${SINGULARITY_CACHEDIR}

CUTADAPT_SIF=${CUTADAPT_SIF}
BWA_SIF=${BWA_SIF}
SAMTOOLS_SIF=${SAMTOOLS_SIF}
BEDTOOLS_SIF=${BEDTOOLS_SIF}
GATK_SIF=${GATK4_SIF}
VCFTOOLS_SIF=${VCFTOOLS_SIF}
EOF

echo
echo "[INFO] wrote config/containers.env"
echo "[INFO] done."