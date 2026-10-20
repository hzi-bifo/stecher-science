# In silico detection of the ICE in *E. faecalis* isolates

Code for **Fig. S9C**: horizontal transfer of an integrative conjugative element (ICE) from *Blautia coccoides* to *Enterococcus faecalis* during gut colonization.

Sequencing reads of each *E. faecalis* isolate were mapped to the *B. coccoides* reference genome. The presence of the ICE in an isolate was determined by the depth of coverage across the element. `plot_coverage_depth.R` plots this coverage over the region containing the ICE (positions 2,100,000–2,500,000 of the reference) for each isolate, in a separate panel.

## Input

One per-position depth file per sample, named `<sample>.depth`, with three tab-separated columns:

| Column | Description |
|---|---|
| contig | Contig or chromosome name |
| position | Position (bp) |
| depth | Number of reads covering the position |

The sample name is taken from the file name (the text before the first `.`).

## Requirements

R with the packages ggplot2, dplyr, forcats, stringr, RColorBrewer and ragg:

```r
install.packages(c("ggplot2", "dplyr", "forcats", "stringr", "RColorBrewer", "ragg"))
```

## Usage

Put the `.depth` files in a folder called `depth_files/` (or change `depth_dir` at the top of the script). The region, samples and colours are also set at the top of the script. Then run:

```bash
Rscript plot_coverage_depth.R
```

## Output

| File | Description |
|---|---|
| `plots/coverage_depth.png` | Coverage plot (PNG) |
| `plots/coverage_depth.svg` | Coverage plot (SVG) |
