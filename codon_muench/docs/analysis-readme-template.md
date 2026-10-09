# Analysis README template

Use the following structure for each top-level contribution folder. Replace the
placeholders with verified information and remove these template instructions.
If an input, command or figure relationship is unknown, state that explicitly.
Do not supply an illustrative command as though it reproduces the manuscript.

## Purpose and current status

Describe the scientific question, the scope of this contribution and the current
reproduction status. Name the actual manuscript version being reproduced.

## Files and workflow

List the scripts, input-data locations and output folders in execution order.
Explain what each step does and which earlier outputs it requires. Identify
external data sources and access requirements without including credentials.

## Relationship to the manuscript

| Figure, table or claim | Source data | Processing / plotting script | Output | Status |
| --- | --- | --- | --- | --- |
| Replace with exact panel or claim | Verified path or accession | Verified path | Exact filename | Confirmed, unverified or unavailable |

Distinguish code that generates a panel from code that supplies its source data.
Document manual layout, experimental images or external software exports.

## Required inputs

Record filenames or accessions, expected formats and sample identifiers, reference
versions and checksums where available. Explain how to obtain data kept outside
the repository and identify any unavailable inputs.

## Software setup

Name the tested environment file or software versions and provide the actual
installation steps. State platform or cluster requirements when relevant.
If no environment has been tested, say so.

## Running the analysis

Provide exact commands in dependency order, including the working directory,
parameters and input/output paths. Describe expected runtime and resources only
when known. Explain any required manual steps and how to resume from intermediates.

## Expected outputs and validation

List generated filenames and how to check successful execution. State what was
actually run, which manuscript values or figures were compared, and any observed
differences. Distinguish synthetic tests from checks using the study data.
Record remaining limitations and any corrections that have not been adopted.

## LLM assistance and author responsibility

Describe the actual scope of LLM assistance for this contribution, if any, such as
coding, debugging, code review or documentation; name tools when known. Do not
attribute LLM use to another contributor without evidence. Keep any disclosure
within that contribution's README and include this responsibility statement:

> The authors retain responsibility for the code and its validation, methodological
> decisions, analyses, interpretation and reported results.

## Provenance and references

Record source repositories, relevant commits, data citations and the manuscript
version. Explain any local-only recovery material so readers of a published copy
do not mistake it for a distributed dependency.
