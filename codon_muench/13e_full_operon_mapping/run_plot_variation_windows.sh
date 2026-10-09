#!/bin/bash
#SBATCH --job-name=operon_variation_windows
#SBATCH --output=operon_variation_windows_%j.out
#SBATCH --error=operon_variation_windows_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
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

python plot_variation_windows.py \
    --combined output_full_run/position_stats/combined_position_summary.tsv \
    --window 10 \
    --output-dir output_full_run/position_stats/variation_windows \
    --legacy-label Legacy \
    --updated-label Updated
