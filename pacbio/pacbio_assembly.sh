#!/usr/bin/env bash
# PacBio HiFi genome assembly workflow
# Usage: bash pacbio_assembly.sh
# Edit the variables below before running.

set -euo pipefail

# ---- Parameters -----------------------------------------------------------
SAMPLE="MS150"            # sample ID; input: ${SAMPLE}.fastq (from SRA) or ${SAMPLE}.hifi_reads.bam
GENOME_SIZE="3.2m"        # expected genome size (canu format)
GENOME_SIZE_RASUSA="3.2mb" # same value, rasusa format
COVERAGE=100              # target coverage for subsampling
SEED=10361518694589224708 # rasusa seed used in the manuscript (100x run)
THREADS=24
MAX_MEM="100g"
CANU_BIN=""               # optional: path to canu-2.2/bin if canu is not on PATH

[[ -n "$CANU_BIN" ]] && export PATH="$PATH:$CANU_BIN"

# ---- 1. Convert HiFi BAM to FASTQ -----------------------------------------
# Skipped if ${SAMPLE}.fastq already exists (e.g. reads downloaded from SRA)
if [[ ! -s "${SAMPLE}.fastq" ]]; then
    bam2fastq -u -o "${SAMPLE}" "${SAMPLE}.hifi_reads.bam"
fi

# Read statistics (total bases are used to estimate input coverage)
seqkit stats -a "${SAMPLE}.fastq" > "${SAMPLE}_stats.txt"

# ---- 2. Subsample reads to target coverage --------------------------------
rasusa reads \
    --coverage "${COVERAGE}" \
    --genome-size "${GENOME_SIZE_RASUSA}" \
    --seed "${SEED}" \
    -o "${SAMPLE}_${COVERAGE}x.fastq" \
    "${SAMPLE}.fastq"

# ---- 3. De novo assembly with Canu ----------------------------------------
ASM_DIR="${SAMPLE}_${COVERAGE}X_${GENOME_SIZE}"
canu -p "${SAMPLE}" -d "${ASM_DIR}" \
    -pacbio-hifi "${SAMPLE}_${COVERAGE}x.fastq" \
    genomeSize="${GENOME_SIZE}" \
    useGrid=false maxMemory="${MAX_MEM}" corThreads="${THREADS}"

CONTIGS="${ASM_DIR}/${SAMPLE}.contigs.fasta"

# ---- 4. Per-contig coverage -----------------------------------------------
pbmm2 align --preset CCS --sort -j "${THREADS}" \
    "${CONTIGS}" "${SAMPLE}.fastq" "${SAMPLE}_${COVERAGE}X.bam"
samtools index "${SAMPLE}_${COVERAGE}X.bam"
samtools idxstats "${SAMPLE}_${COVERAGE}X.bam" > "${SAMPLE}_${COVERAGE}X_idxstats.txt"

# ---- 5. Circularity check (self-alignment) --------------------------------
# Contigs flagged suggestCircular=yes in the canu header are checked for
# overlapping (duplicated) ends.
nucmer --maxmatch -l 100 -p "${SAMPLE}_self" "${CONTIGS}" "${CONTIGS}"
show-coords -rcl "${SAMPLE}_self.delta" > "${SAMPLE}_self.coords"

echo "Done. Assembly: ${CONTIGS}"
