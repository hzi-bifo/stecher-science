# PacBio HiFi genome assembly

Scripts used to assemble bacterial genomes from PacBio HiFi reads for the manuscript.

## Data

Raw PacBio HiFi reads are available from NCBI SRA under BioProject [PRJNA1294738](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1294738).

> **Note:** The data will be released on 31 December 2026 or upon publication, whichever comes first. Until then, the commands below will not return any runs.

To list the runs in the BioProject with their sample names:

```bash
esearch -db sra -query PRJNA1294738 | efetch -format runinfo | cut -d ',' -f 1,30
```

Then download the run for a sample and name the file after the sample (replace `<SRR>` with the run accession):

```bash
prefetch <SRR>
fasterq-dump <SRR> -o MS150.fastq
```

The runs can also be browsed and downloaded in the [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA1294738).

## Requirements

All tools can be installed with conda:

```bash
conda env create -f environment.yml
conda activate pacbio
```

| Tool | Purpose |
|---|---|
| SRA Toolkit, Entrez Direct | Find and download reads from SRA |
| pbtk (`bam2fastq`) | Convert HiFi BAM to FASTQ (only needed when starting from BAM) |
| SeqKit | Read statistics |
| Rasusa | Subsample reads to a target coverage |
| Canu 2.2 | De novo assembly |
| pbmm2 | Map reads back to contigs |
| SAMtools | Per-contig coverage |
| MUMmer4 (`nucmer`) | Check contigs for circularity |

## Workflow

1. **Convert reads.** HiFi reads (`<sample>.hifi_reads.bam`) are converted to FASTQ with `bam2fastq`. This step is skipped when starting from the SRA FASTQ. Read statistics are computed with `seqkit stats`.
2. **Subsample.** The raw data had ~448× coverage (1,432,304,191 bp for a 3.2 Mb genome). Reads were subsampled to 100× with Rasusa (seed `10361518694589224708`). 60× and 150× subsets were also tested.
3. **Assemble.** The 100× subset was assembled with Canu in HiFi mode (`genomeSize=3.2m`).
4. **Per-contig coverage.** All reads were mapped back to the contigs with pbmm2 (CCS preset), and coverage per contig was summarised with `samtools idxstats`.
5. **Circularity.** Contigs flagged `suggestCircular=yes` by Canu were checked for overlapping ends by self-alignment with `nucmer` / `show-coords`.

## Usage

Put `<sample>.fastq` (downloaded from SRA, see [Data](#data)) or `<sample>.hifi_reads.bam` in the working directory, set the parameters at the top of `pacbio_assembly.sh`, then run:

```bash
bash pacbio_assembly.sh
```

## Outputs

| File | Description |
|---|---|
| `<sample>_stats.txt` | Read statistics |
| `<sample>_100x.fastq` | Subsampled reads |
| `<sample>_100X_3.2m/<sample>.contigs.fasta` | Assembled contigs |
| `<sample>_100X_idxstats.txt` | Mapped reads per contig |
| `<sample>_self.coords` | Self-alignment coordinates for checking circularity |
