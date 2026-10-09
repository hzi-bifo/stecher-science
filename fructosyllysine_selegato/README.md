# Fructosyllysine quantification and metabolomics data cleaning

Scripts contributed by **Denise Selegato** for the targeted quantification of
fructosyllysine and preprocessing of untargeted metabolomics data in the study
by Silva, Woelfel et al.

## Scripts

| Script | Purpose | Feature-table input |
| --- | --- | --- |
| [Bacth2_Targeted_Quantification.R](Bacth2_Targeted_Quantification.R) | Batch 2: calibration-based quantification, sample-volume and tissue-weight calculations, concentration tables and plots | `20241203_Quant_table_SamplesM.csv` |
| [Bacth3_Targeted_Quantification.R](Bacth3_Targeted_Quantification.R) | Batch 3: quantification using the batch-specific calibration and sample preparation, concentration tables and plots | `Quant_Table_20241107-M.csv` |
| [Untargeted_DataCleaning.R](Untargeted_DataCleaning.R) | Feature-table and metadata alignment, blank filtering, weight normalization, imputation, quantile and total-area normalization | `Filtered_annotatedEntities.csv` |

Each script also reads a batch-specific `metadata.csv`. The targeted scripts
write tables and plots under `BoxplotsM/`; the untargeted script writes cleaned
and normalized tables under `DataCleanup_Results/`.

## Use

Open the relevant script in R or RStudio and provide its feature table and
metadata. The `Directory` setting and working directory should point to the
corresponding batch's data folder; adapt paths in a local working copy. Required
R packages are listed at the start of each script, including `preprocessCore`
from Bioconductor. Run the scripts separately for their respective datasets.

The scripts are preserved exactly as supplied, including their original filenames.
The untargeted script credits its adaptation from the Nature Protocols workflow
identified in its header (DOI: `10.1038/s41596-024-01046-3`).

## Scope

This contribution contains quantification and data-cleaning scripts. Marta and
Simon performed the statistical analyses separately; that statistical code is a
separate contribution.
