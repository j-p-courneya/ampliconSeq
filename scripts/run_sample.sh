#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source config/containers.env

sample_id="$1"
r1="$2"
r2="$3"

threads="${SLURM_CPUS_PER_TASK:-4}"
outdir="results/${sample_id}"
tmpwork="${SLURM_TMPDIR:-$TMPDIR}/ampliconSeq_${sample_id}"
mkdir -p "$outdir" "$tmpwork" logs

echo "[INFO] sample=${sample_id} threads=${threads}"
echo "[INFO] versions:"
bash scripts/ctr_exec.sh "$CUTADAPT_SIF" cutadapt --version
bash scripts/ctr_exec.sh "$BWA_SIF" bwa 2>&1 | head -n 2
bash scripts/ctr_exec.sh "$SAMTOOLS_SIF" samtools --version | head -n 2
bash scripts/ctr_exec.sh "$BEDTOOLS_SIF" bedtools --version
bash scripts/ctr_exec.sh "$GATK_SIF" gatk --version
bash scripts/ctr_exec.sh "$VCFTOOLS_SIF" vcftools --version

##############################################################################
# PIPELINE SECTION: replace below with exact ampliconSeq commands in your repo
##############################################################################

# 1) cutadapt
bash scripts/ctr_exec.sh "$CUTADAPT_SIF" cutadapt \
  -j "$threads" \
  -o "${outdir}/${sample_id}_R1.trim.fastq.gz" \
  -p "${outdir}/${sample_id}_R2.trim.fastq.gz" \
  "$r1" "$r2"

# 2) bwa mem
bash scripts/ctr_exec.sh "$BWA_SIF" bwa mem -t "$threads" \
  ref/genome.fa \
  "${outdir}/${sample_id}_R1.trim.fastq.gz" \
  "${outdir}/${sample_id}_R2.trim.fastq.gz" \
  > "${outdir}/${sample_id}.sam"

# 3) samtools sort/index
bash scripts/ctr_exec.sh "$SAMTOOLS_SIF" samtools sort -@ "$threads" \
  -o "${outdir}/${sample_id}.bam" "${outdir}/${sample_id}.sam"
bash scripts/ctr_exec.sh "$SAMTOOLS_SIF" samtools index "${outdir}/${sample_id}.bam"

# 4) optional bedtools/gatk/vcftools stages
# bash scripts/ctr_exec.sh "$BEDTOOLS_SIF" bedtools ...
# bash scripts/ctr_exec.sh "$GATK_SIF" gatk ...
# bash scripts/ctr_exec.sh "$VCFTOOLS_SIF" vcftools ...

echo "[INFO] done ${sample_id}"