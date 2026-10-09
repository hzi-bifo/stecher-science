# Muench operon contribution

## Purpose and current status

This section documents the potential operon contribution and is the entry point
for its code and data once their manuscript provenance is established.

**Status: manuscript provenance unresolved.** No script or dataset from the
supplied exploratory repository has been confirmed as an input to a published
panel. Accordingly, this directory currently contains documentation only.

## Files and how to use them

| File | Purpose |
| --- | --- |
| `README.md` | This guide, source requirements and validation status |
| [figure_manifest.json](figure_manifest.json) | Panel status, described method, missing sources and fields for verified inputs, commands and outputs |
| [Figure-to-code index](../docs/figure-code-map.md) | Human-readable panel mapping with page references to the reviewed paper and supplement |

1. Read the figure-to-code index to identify the panel and its described method.
2. Check its entry in `figure_manifest.json`. Empty source, command and output
   fields mean the required provenance is missing; they are not runnable steps.
3. Obtain the original inputs and identify the actual generating workflow before
   attempting to reproduce the panel. The materials needed are listed below.

## Relationship to the manuscript

The two possible reference connections are the operon schematic in Fig. 4C and
the mutation diagram in Fig. S6C. The archived KB1 GenBank annotations are candidate
shared inputs, not established sources. They and the population mapping scripts
remain recoverable locally rather than being distributed as manuscript analyses.

## Required inputs

For Fig. S6C, the next useful material is the original diagram/source export,
per-isolate mutation table and Geneious project or variant-call export. These
would establish whether any archived code or reference file belongs here.

For Fig. 4C, the editable schematic and reference accession/coordinates are
needed. The figure-to-code index lists requirements for the other related panels;
their assignment to this contribution is also unconfirmed.

## Software setup, execution and outputs

No software environment or executable workflow is distributed in this section
yet. There is currently no command that reproduces a manuscript panel and no
verified figure output included here. Reading the Markdown and JSON files requires
no scientific software installation.

When a relationship is confirmed, add only the required input data and scripts,
document the command and software versions, and identify the exact figure panel
and output files. Do not require a population analysis merely because its genes
or mutation coordinates also occur in the paper.

Document execution steps in dependency order, with the working directory and
exact commands, then list the expected output filenames and any manual figure
assembly. Use the [analysis README template](../docs/analysis-readme-template.md)
when extending this guide.

## Validation and recovery

The current checks establish that documentation links and the figure manifest
are consistent. They do not validate or reproduce manuscript results. The archived
exploratory code had separate checks; those must not be presented as validation
of an unconfirmed manuscript workflow.

Recovery locations and source hashes are recorded in
[provenance.json](../docs/provenance.json). Local archives are excluded from the
publication branch and may not be available in a downloaded copy of this repository.

## LLM assistance and author responsibility

LLM tools, including OpenAI Codex, assisted with code review, proposed bug fixes,
documentation and organization of this contribution during repository preparation.
The authors retain responsibility for the code and its validation, methodological
decisions, analyses, interpretation and reported results. This assistance does
not imply that manuscript reproduction has been completed. See the
[repository-wide disclosure](../README.md#llm-assistance-and-author-responsibility).
