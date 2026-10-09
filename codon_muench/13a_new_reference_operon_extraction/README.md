# Updated KB1 reference extraction

`FL_operon_with_SNPs.gb` contains the updated KB1 operon and its annotated
variation sites. Run from this directory:

```sh
python extract_operon_genes.py
```

Outputs in `output/` include `operon_genes.tsv`, `operon_variations.tsv`, coding
nucleotide/protein FASTAs and a regulatory-sequence FASTA. Override the paths with
`--gb` and `--output`. Regulatory annotations include short motifs; their reported
coordinates describe those motifs.

Use the [contribution guide](../README.md) for environment setup and the plotting workflow.
