# Operon analysis — Münch contribution

Reference extraction, full-operon sequence mapping and visualization, and
population-level organization and conservation analysis of the
fructoselysine/glucoselysine utilization operon in *Enterococcus faecalis*.

The organization and conservation analyses support **Fig. S13A–C**, the Methods
sections **“Fructoselysine operon organization analysis”** and **“Core gene
analysis”**, and the associated conservation result in the main text of
**Gut microbiota within-host evolution enforces colonization resistance against
enteric infection** by Silva, Woelfel et al. The population analysis includes
8,596 genomes: 8,573 EnteroBase genomes and 23 infant isolates.

## Contents

| Folder | Analysis |
| --- | --- |
| [data](data/) | Reference and result-table index, file checksums and recovered assembly filenames |
| [01_prokka_annotation](01_prokka_annotation/) | Genome annotation with Prokka |
| [02_reference_operon_extraction](02_reference_operon_extraction/) | Extract nucleotide/protein sequences and gene coordinates from the original reference |
| [03_blast_search](03_blast_search/) | Operon homology searches and saved BLAST hits |
| [04_core_gene_analysis](04_core_gene_analysis/) | Core-gene identification, alignment and conservation |
| [05_operon_assembly_extraction](05_operon_assembly_extraction/) | Operon sequence extraction, alignment and conservation |
| [06_diversity_analysis](06_diversity_analysis/) | Comparative conservation rankings and plots (S13C) |
| [09_operon_order_analysis](09_operon_order_analysis/) | Operon organization and gene-order plots (S13A–B) |
| [13a_new_reference_operon_extraction](13a_new_reference_operon_extraction/) | Extract genes and annotated variation sites from the updated KB1 reference |
| [13e_full_operon_mapping](13e_full_operon_mapping/) | Map both references to assemblies and plot coverage, mismatches, indels and variation windows |
| [tests](tests/) | Regression checks for alignment coverage and insertion-site calls |

## Setup

From the repository root:

```sh
conda env create -f codon_muench/environment.yml
conda activate efs_diversity
```

BLAST+ is used for assembly mapping. Reference extraction and plotting use
Biopython, pandas, NumPy and Matplotlib.

## Fig. S13: plots and supporting data

The plots below were used in preparing Fig. S13; the manuscript adapts their
layout, colors and gene labels.

| Panel | Analysis | Plot | Supporting data |
| --- | --- | --- | --- |
| S13A | Representative operon gene arrangements | [Gene-order PDF](09_operon_order_analysis/output/gene_order_visualization.pdf) | [BLAST hits](03_blast_search/output/all_blast_hits_detailed.csv.gz), [genome list and presence](03_blast_search/output/operon_summary.csv) |
| S13B | Distribution of operon organization types | [Organization PNG](09_operon_order_analysis/output/operon_organization_types.png) | Same BLAST data; [organization summary](09_operon_order_analysis/output/operon_order_summary.txt) |
| S13C | Operon conservation relative to core genes | [Ranking PNG](06_diversity_analysis/output/conservation_ranking_bars.png), [PDF](06_diversity_analysis/output/conservation_ranking_bars.pdf) | [Operon scores and ranks](06_diversity_analysis/output/operon_conservation_summary.csv), [core-gene scores](04_core_gene_analysis/output/core_gene_conservation_metrics.csv) |

Gene names in the analysis correspond to the manuscript labels as follows:
`fruR` → Regulator; `ptsA`, `ptsB`, `ptsC`, `ptsD` → `gfrA`, `gfrB`, `gfrC`,
`gfrD`; `glpC` → `gfrE`; `frpC` → `gfrF`.

### Generate S13 plots from the included data

From the repository root:

```sh
cd codon_muench
conda activate efs_diversity
python reproduce_s13.py --output-dir reproduced
```

For S13A–B, this command reads the compressed BLAST table, applies the gene-order
analysis to the genomes in `operon_summary.csv`, and writes per-genome results,
category counts and the two plots. Hits are filtered at ≥80% identity and
bitscore ≥50, retaining the highest-bitscore hit for each gene.

For S13C, it plots the included operon scores and ranks alongside the ten highest
and ten lowest core-gene scores. This plotting step reads the saved summary
values; sequence-based scoring is performed by the analysis scripts below.
The S13C replot uses the manuscript gene labels and a three-panel layout.

Run one part with `--panels AB` or `--panels C`. Output files are written to the
chosen output directory, leaving the supplied tables and plot exports intact.

## Generate full-operon mapping plots from the saved tables

Extract the updated reference annotations, then plot the included position tables:

```sh
cd codon_muench
python 13a_new_reference_operon_extraction/extract_operon_genes.py
cd 13e_full_operon_mapping
python generate_position_plots.py \
  --input output_full_run/position_stats/combined_position_summary.tsv \
  --legacy-annotation ../02_reference_operon_extraction/output/operon_genes.tsv \
  --updated-annotation ../13a_new_reference_operon_extraction/output/operon_genes.tsv \
  --output-dir output_replotted/position_plots
python plot_variation_windows.py \
  --combined output_full_run/position_stats/combined_position_summary_known_variations.tsv \
  --output-dir output_replotted/variation_windows
python plot_variation_slices.py \
  --summary output_full_run/position_stats/combined_position_summary_known_variations.tsv \
  --counts output_full_run/position_stats/coverage_counts.tsv \
  --output-dir output_replotted/variation_slices
```

### Plot scripts and outputs

| Script | Plot | Output filenames |
| --- | --- | --- |
| `generate_position_plots.py` | Coverage, mismatch, deletion and insertion profiles along each reference, with regulatory-region details | `legacy_*.png`, `updated_*.png`, and detailed-region PDFs |
| `plot_variation_windows.py` | Mismatch and deletion rates around annotated sites | `variation_<position>_<gene>.png` |
| `plot_variation_slices.py` | Match, mismatch and gap proportions at individual sites | `variation_slice_<position>_<gene>.png` |
| `plot_mapping_results.py` | Identity comparison between the two references | `identity_scatter.png` |
| `analyze_updated_operon_variants.py` | Allele counts at selected variant sites | Filename supplied with `--figure-out` |

The first three commands use the saved tables included here. The identity plot
uses a `full_operon_mapping.tsv` generated by the mapping step; allele calls use
its raw BLAST alignments. See the [mapping guide](13e_full_operon_mapping/README.md)
for those commands. Plot names identify the corresponding script outputs.

## Data and checks

`output_full_run/` contains the original saved mapping summaries and plot exports.
Rebuilding the mapping tables uses the assembly or raw alignment inputs. The commands above replot saved values into a separate folder.

Run the regression checks from the repository root:

```sh
python -m unittest discover -s codon_muench/tests -v
```

## Sequence-level organization and conservation workflow

Run the numbered stages in order: annotation (`01`), reference extraction (`02`),
BLAST (`03`), core-gene analysis (`04`), operon alignment (`05`), and comparative
conservation (`06`). The organization analysis (`09`) uses the BLAST results.

For sequence-level runs, supply the genome assemblies, Prokka annotations and
per-genome BLAST results. Install Prokka, NCBI BLAST+ and MAFFT in the compute
environment. The manuscript specifies Prokka 1.14.6 and MAFFT 7.313.

Run the scripts from their numbered directories. For example, an operon
extraction and alignment run uses:

```sh
cd 05_operon_assembly_extraction
python operon_pipeline.py extract-sequences \
  --blast-dir /path/to/blast_results \
  --assemblies-dir /path/to/Efs_assemblies \
  --source assemblies --min-identity 90 --min-coverage 80 \
  --output-dir /path/to/run/sequences
python operon_pipeline.py create-msa \
  --sequences-dir /path/to/run/sequences \
  --output-dir /path/to/run/msa --threads 16
python operon_pipeline.py create-detailed-summary \
  --msa-dir /path/to/run/msa \
  --output-file /path/to/run/operon_conservation_metrics_detailed.csv
```

Core-gene scoring uses alignments named `*_aligned.fasta` in
`04_core_gene_analysis/output/core_gene_alignments/`. Operon DNA alignments use
`05_operon_assembly_extraction/output/msa/dna_alignments/`. Each pipeline's
`--help` lists its input paths and execution options.

The Prokka entry point accepts a file of absolute assembly paths with
`--genome-list`. It writes annotations to `codon_muench/prokka_output/`; pass
that directory explicitly as `--prokka-dir` to downstream analyses. Set
`MAFFT_TMPDIR` to a writable temporary directory for the core-gene pipeline.

Supporting tables include the core-gene list, gene prevalence, conservation
metrics, operon gene co-occurrence and non-canonical gene orders. File integrity
can be checked from this directory with:

```sh
shasum -a 256 -c checksums.sha256
```

## LLM assistance

LLM tools, including OpenAI Codex and Claude Code, assisted with coding, code review and
documentation for this contribution. The authors retain responsibility for the
code and its validation, methodological decisions, analyses, interpretation and
reported results.
