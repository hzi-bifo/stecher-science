# Full-operon mapping and plots

Compare the original and updated reference operons against genome assemblies,
then summarize and visualize aligned positions and selected variant sites.

## Plot the included summaries

The [contribution guide](../README.md#generate-plots-from-the-saved-tables) provides
commands for whole-operon profiles, variant windows and per-site allele slices.
The saved numerical inputs are in `output_full_run/position_stats/`.

## Map genome assemblies

Run from this directory, with the analysis environment activated. Replace the
assembly path with the directory containing the study assemblies:

```sh
python compare_full_operon_mapping.py \
  --legacy-gb ../02_reference_operon_extraction/operon.gb \
  --updated-gb ../13a_new_reference_operon_extraction/FL_operon_with_SNPs.gb \
  --assemblies-dir /path/to/assemblies \
  --output output_rerun --threads 4 \
  --min-coverage 80 --min-identity 90 --save-raw
python plot_mapping_results.py output_rerun/full_operon_mapping.tsv \
  --output-dir output_rerun/plots
```

This produces per-assembly mapping metrics, a summary, raw BLAST alignments in
`output_rerun/raw_blast/`, and an identity comparison plot. `--max-assemblies`
limits the run for a small trial. Coverage is the fraction of the reference query
spanned by the alignment.

## Aggregate selected variant sites

```sh
python analyze_updated_operon_variants.py output_rerun/raw_blast/updated \
  --site-summary output_rerun/variant_site_summary.tsv \
  --site-table output_rerun/variant_site_allele_counts.tsv \
  --site-calls output_rerun/variant_site_calls.tsv \
  --figure-out output_rerun/variant_site_counts.png
```

The command uses this script's original default identity/coverage thresholds
(both zero); set `--min-identity` and `--min-coverage` explicitly to apply a
specified analysis protocol. Its filters are separate from the mapping-summary
thresholds. An insertion absence requires alignment support across both flanks.

`process_raw_blast.py` builds per-position count/rate tables from raw alignments;
`annotate_position_summary.py` adds gene and known-variation labels. Their `--help`
options specify required paths. Shell wrappers provide the original SLURM run
entry points; adapt resource settings and input paths for your cluster. Set
`OPERON_SKIP_CONDA=1` when using an already activated environment.

## Saved outputs

`output_full_run/` contains tables and figures from the original repository.
`output_replotted/` and `output_rerun/` keep new plots and analyses separate.
The included saved tables precede the coverage/callability corrections in the
mapping code. Use raw alignments to regenerate those values under the fixes.
