# Figure-to-code index

Scope: the potential operon contribution, not every analysis in the paper.
Version reviewed: bioRxiv 2026.03.27.714693v1, posted March 28, 2026.

**No generator or source-data link has yet been confirmed for the supplied code.**
This index documents what the paper describes and which materials are needed.
It does not assign these panels to the user's contribution without evidence.

| Panel | Reported content / method | Code or data included here | Source status and next material needed |
| --- | --- | --- | --- |
| Fig. 4C | Operon gene organization and biochemical pathway schematic | None confirmed | Possible shared reference annotations. Obtain the editable diagram and reference accession/coordinates used. No plotting command established. |
| Fig. S6C | Operon mutations in the study's evolved isolates; methods describe Geneious read-based variant calling | None confirmed | Obtain the diagram source and per-isolate mutation calls. Archived KB1 annotations may share an upstream source, but the relationship is unverified. |
| Fig. S6D | SW328 sequencing-read coverage mapped against KB1 | Source not supplied | Need the read-mapping/coverage inputs and plotting procedure. This is distinct from assembly-BLAST alignment coverage. |
| Fig. S6E | Metagenomic coverage inside the operon relative to an outside region, and association with pathogen load | Source not supplied | Need sample-level coverage, phenotype data and analysis/plotting code. Population BLAST summaries do not reproduce this panel. |
| Fig. 5C | Seven infant isolates and two reference strains; methods specify kSNP4.1 and iTOL | Source not supplied | Need the study-isolate tree inputs, kSNP workflow and iTOL export. The archived 8,587-tip population tree is a different analysis. |
| Fig. S7E | Experimental gfrEF PCR gel | Experimental source not supplied | Need gel source image and sample/lane mapping if included in this contribution. Population gene-presence code does not generate this panel. |

## Evidence locations

Page numbers refer to the PDFs supplied for review; PDF hashes are recorded in
[provenance.json](provenance.json). The PDFs themselves are not included.

| Item | Main PDF, 60 pages | Supplement PDF, 42 pages |
| --- | --- | --- |
| Fig. 4C | p.18 | — |
| Fig. 5C and its methods | pp.19-20,27-28 | p.10 |
| Fig. S6C-D and variant-calling methods | pp.7,27,42-43 | pp.9-10,26-27 |
| Fig. S6E and coverage/statistical methods | pp.31-33,42-43 | pp.15-17,26-27 |
| Fig. S7E | p.44 | p.28 |

The reviewed PDFs do not report the exploratory conservation rankings, codon
ratios, start-codon survey or large population prevalence analysis. These analyses
and their audit outputs are excluded from this publication branch. Neither their
bugs nor their corrected values should be attributed to the paper without an
actual dependency.

## Filling a verified entry

For each confirmed panel or claim, record its source files, processing script,
exact run command, environment, generated output and any manual figure assembly.
Record whether the code generates the panel itself or only its source data.
The [figure manifest](../muench_operon/figure_manifest.json) holds the same source
status in a machine-readable form; currently all generator fields are null.
