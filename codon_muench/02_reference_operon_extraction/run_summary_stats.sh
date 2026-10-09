#!/bin/bash
#SBATCH --job-name=ref_operon_stats
#SBATCH --output=manuscript_stats_%j.out
#SBATCH --error=manuscript_stats_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
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


echo "=========================================="
echo "Starting manuscript statistics generation"
echo "Job ID: $SLURM_JOB_ID"
echo "Date: $(date)"
echo "=========================================="

# Initialize conda
echo "Activating conda environment..."
operon_activate_environment efs_diversity || exit 1
echo "Conda environment activated: ${CONDA_DEFAULT_ENV:-active environment}"

# Show working directory
echo "Working directory: $(pwd)"

# Check input files
echo "Checking for input files..."
if [ -f "operon.gb" ]; then
    echo "Found GenBank file: operon.gb"
    echo "File size: $(ls -lh operon.gb | awk '{print $5}')"
else
    echo "WARNING: GenBank file 'operon.gb' not found"
fi

# Check output directory
echo "Checking for output files..."
if [ -d "output" ]; then
    FILE_COUNT=$(ls -1 output/*.fasta output/*.tsv 2>/dev/null | wc -l)
    echo "Found $FILE_COUNT output files in output/"
else
    echo "WARNING: Output directory not found"
fi

echo "=========================================="
echo "Running summarize_results.py..."
echo "=========================================="

# Run with verbose Python output
python -u summarize_results.py analysis_stats.txt

echo "=========================================="
echo "Statistics generation complete at $(date)"
echo "Output saved to analysis_stats.txt"
echo "=========================================="

# Show summary of output file
if [ -f "analysis_stats.txt" ]; then
    echo "Output file size: $(ls -lh analysis_stats.txt | awk '{print $5}')"
    echo ""
    echo "First 20 lines of output:"
    head -20 analysis_stats.txt
fi