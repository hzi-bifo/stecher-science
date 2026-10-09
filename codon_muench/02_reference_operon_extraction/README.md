# Original reference extraction

`operon.gb` contains the original reference operon. Run from this directory:

```sh
python extract_operon_genes.py
```

The script writes the gene-coordinate table, nucleotide sequences, protein
sequences and noncoding sequences to `output/`. These files provide the original
reference annotations for the full-operon mapping plots.

Use the [contribution guide](../README.md) for environment setup and the plotting workflow.
