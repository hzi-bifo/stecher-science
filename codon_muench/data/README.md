# Data and tables

The reference sequences and saved result tables are stored alongside their
analysis steps. Use this index to locate inputs and reproduce the plots.

| Data | Location | Contents |
| --- | --- | --- |
| Original reference | [Reference extraction](../02_reference_operon_extraction/) | GenBank sequence, gene coordinates, nucleotide and protein FASTA files |
| Updated KB1 reference | [Updated reference extraction](../13a_new_reference_operon_extraction/) | Annotated GenBank sequence, extracted genes, regulatory motifs and variant coordinates |
| Position tables | [Position statistics](../13e_full_operon_mapping/output_full_run/position_stats/) | Coverage, mismatch, deletion and insertion summaries used by the plotting scripts |
| Variant tables | [Mapping results](../13e_full_operon_mapping/output_full_run/) | Per-assembly allele calls, allele counts and site summaries |
| Assembly filenames | [Recovered filename list](assembly_filenames_from_variant_calls.txt) | 8,586 unique assembly filenames present in the saved variant-call table |
| File inventory | [Inventory and checksums](file_inventory.tsv) | Paths relative to `codon_muench/`, file sizes in bytes and SHA-256 checksums for the included reference and result data |

## Reproduce the plots

Follow the [plotting commands](../README.md#generate-plots-from-the-saved-tables)
to generate figures from the included numerical tables.

## Rerun the mapping

The recovered filename list is the sorted, unique `assembly` column from
`13e_full_operon_mapping/output_full_run/variant_site_calls.tsv`. It identifies
assemblies represented in that output. The original mapping summary reports
8,596 scanned assemblies, so this list does not establish the complete input
cohort. The filenames are local identifiers rather than public download
accessions.

A full rerun needs the original assembly FASTA files, or a source accession list
that identifies them. Assembly sequences, download accessions and sample metadata
were not present in the archived repository. Once the assemblies are available,
follow the [mapping instructions](../13e_full_operon_mapping/README.md#map-genome-assemblies).

The saved numerical tables are the original outputs. Reruns with the corrected
mapping code write to a separate directory for comparison.
