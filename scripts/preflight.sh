#!/usr/bin/env bash
set -euo pipefail

source config/runtime.env

echo "[INFO] Running preflight checks..."

[[ -f "${SAMPLES_TSV}" ]] || { echo "[ERROR] Missing ${SAMPLES_TSV}"; exit 1; }
mkdir -p logs results "${APPTAINER_SIF_DIR}" "${APPTAINER_CACHEDIR}"

if [[ "${RUNTIME_MODE}" == "apptainer" || "${RUNTIME_MODE}" == "auto" ]]; then
  command -v apptainer >/dev/null 2>&1 || {
    if [[ "${RUNTIME_MODE}" == "apptainer" ]]; then
      echo "[ERROR] apptainer not found, and RUNTIME_MODE=apptainer"
      exit 1
    else
      echo "[WARN] apptainer not found; auto mode will fall back to conda"
    fi
  }
fi

if [[ "${RUNTIME_MODE}" == "conda" || "${RUNTIME_MODE}" == "auto" ]]; then
  [[ -f "${CONDA_SH}" ]] || {
    if [[ "${RUNTIME_MODE}" == "conda" ]]; then
      echo "[ERROR] conda init script not found: ${CONDA_SH}"
      exit 1
    else
      echo "[WARN] conda init script missing; fallback may fail"
    fi
  }
fi

# quick samples sanity
awk 'NF<3{print "[ERROR] bad row in samples.tsv:", $0; bad=1} END{exit bad}' "${SAMPLES_TSV}"

echo "[INFO] Preflight checks passed."