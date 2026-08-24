#!/usr/bin/env bash
#SBATCH --job-name=ampliconSeq
#SBATCH --account=cvd
#SBATCH --partition=all
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=24:00:00
#SBATCH --array=1-200
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --mail-user=jean-paul.courneya@som.umaryland.edu  # Email for notifications
#SBATCH --mail-type=ALL           # Send email on job start, end, and failure
#!/usr/bin/env bash
#SBATCH --job-name=ampliconSeq
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=24:00:00
#SBATCH --array=1-1
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

SAMPLES_TSV="${SAMPLES_TSV:-metadata/samples.tsv}"
line="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES_TSV")"

sample_id="$(awk '{print $1}' <<< "$line")"
r1="$(awk '{print $2}' <<< "$line")"
r2="$(awk '{print $3}' <<< "$line")"

bash scripts/run_sample.sh "$sample_id" "$r1" "$r2"