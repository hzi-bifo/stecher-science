#!/bin/bash
#SBATCH --job-name=operon_variant_summary
#SBATCH --output=operon_variant_summary_%j.out
#SBATCH --error=operon_variant_summary_%j.err
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

cd "$ANALYSIS_ROOT" || exit 1

operon_activate_environment efs_diversity || exit 1

./13e_full_operon_mapping/analyze_updated_operon_variants.py \
  --site-summary 13e_full_operon_mapping/output_full_run/variant_site_summary.tsv \
  --site-table 13e_full_operon_mapping/output_full_run/variant_site_allele_counts.tsv \
  --site-calls 13e_full_operon_mapping/output_full_run/variant_site_calls.tsv \
  --figure-out 13e_full_operon_mapping/output_full_run/variant_site_counts.png
