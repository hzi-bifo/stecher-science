#!/bin/bash
#SBATCH --job-name=operon_raw_stats
#SBATCH --output=operon_raw_stats_%j.out
#SBATCH --error=operon_raw_stats_%j.err
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=cpu

# Locate this analysis when called locally or from a SLURM spool directory.
ANALYSIS_ROOT="${OPERON_ANALYSIS_ROOT:-}"
if [[ -z "$ANALYSIS_ROOT" ]]; then
    for operon_base in "${SLURM_SUBMIT_DIR:-}" "$(dirname "${BASH_SOURCE[0]}")" "$PWD"; do
        [[ -n "$operon_base" ]] || continue
        for operon_candidate in "$operon_base" "$operon_base/.." "$operon_base/codon_muench"; do
            if [[ -f "$operon_candidate/runtime.sh" ]]; then
                ANALYSIS_ROOT="$(cd "$operon_candidate" && pwd)"
                break 2
            fi
        done
    done
fi
if [[ ! -f "$ANALYSIS_ROOT/runtime.sh" ]]; then
    echo "Cannot locate analysis runtime. Set OPERON_ANALYSIS_ROOT to the codon_muench directory." >&2
    exit 1
fi
source "$ANALYSIS_ROOT/runtime.sh"


set -euo pipefail

cd "$ANALYSIS_ROOT/13e_full_operon_mapping" || exit 1

operon_activate_environment efs_diversity || exit 1

python process_raw_blast.py \
    --legacy-raw output_full_run/raw_blast/legacy \
    --updated-raw output_full_run/raw_blast/updated \
    --legacy-reference ../02_reference_operon_extraction/operon.gb \
    --updated-reference ../13a_new_reference_operon_extraction/FL_operon_with_SNPs.gb \
    --min-identity 90 \
    --min-coverage 80 \
    --output output_full_run/position_stats
