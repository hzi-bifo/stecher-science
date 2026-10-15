#!/usr/bin/env python3
"""Plot the Fig. S13 analyses from the distributed BLAST and conservation tables.

Panels A/B use the original operon-organization analysis and plotting functions.
Panel C replots saved conservation scores and operon ranks with manuscript names.
"""

import argparse
import importlib.util
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parent
GENE_NAMES = {
    "fruR": "Regulator", "ptsA": "gfrA", "ptsB": "gfrB", "ptsC": "gfrC",
    "ptsD": "gfrD", "glpC": "gfrE", "frpC": "gfrF",
}
PANEL_FILES = {
    "AB": (
        "operon_order_analysis.csv", "operon_organization_counts.csv",
        "operon_organization_types.png", "gene_order_visualization.pdf",
    ),
    "C": (
        "s13c_operon_values.csv", "s13c_core_genes.csv",
        "s13c_conservation_ranking.png", "s13c_conservation_ranking.pdf",
    ),
}


def check_output_directory(value, panels):
    """Keep new figures separate from the distributed scripts and input tables."""
    output = Path(value).expanduser().resolve()
    if output == ROOT or output in ROOT.parents:
        raise ValueError("Choose a separate output directory, such as reproduced/.")
    if output.is_relative_to(ROOT) and not output.is_relative_to(ROOT / "reproduced"):
        raise ValueError("Outputs inside this contribution must go under reproduced/.")
    if output.exists() and not output.is_dir():
        raise ValueError(f"Output path is not a directory: {output}")
    for panel in panels:
        for filename in PANEL_FILES[panel]:
            destination = output / filename
            if destination.is_symlink() or destination.resolve().parent != output:
                raise ValueError(f"Output must not follow a file symlink: {destination}")
            if destination.exists() and not destination.is_file():
                raise ValueError(f"Output path is not a regular file: {destination}")
    return output


def reproduce_ab(output):
    """Apply the original classifier to the saved cohort and detailed BLAST hits."""
    import pandas as pd

    source = ROOT / "09_operon_order_analysis" / "operon_order_pipeline.py"
    spec = importlib.util.spec_from_file_location("s13_operon_order", source)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    columns = [
        "genome_id", "search_type", "qseqid", "sseqid", "pident", "sstart",
        "send", "evalue", "bitscore",
    ]
    blast = pd.read_csv(
        ROOT / "03_blast_search/output/all_blast_hits_detailed.csv.gz",
        usecols=columns,
    )
    cohort = pd.read_csv(
        ROOT / "03_blast_search/output/operon_summary.csv", usecols=["genome_id"],
    )["genome_id"]
    if cohort.isna().any() or cohort.duplicated().any():
        raise ValueError("The cohort table must contain unique, nonempty genome IDs.")
    blast = blast.loc[blast["search_type"] == "tblastn"]
    if blast[columns].isna().any().any():
        raise ValueError("The tblastn table contains missing hit fields.")
    if set(blast["genome_id"]) - set(cohort):
        raise ValueError("BLAST hits contain genome IDs absent from the cohort table.")
    # groupby preserves the source-row order within each genome, including ties.
    grouped = {genome: rows for genome, rows in blast.groupby("genome_id", sort=False)}

    class TableAnalyzer(module.OperonOrderAnalyzer):
        def parse_blast_file(self, genome_id):
            """Adapt saved CSV rows to the original parser's hit dictionaries."""
            rows = grouped.get(genome_id)
            if rows is None:
                return []
            return [
                {
                    "query": row.qseqid,
                    "subject": row.sseqid,
                    "identity": row.pident,
                    "start": min(row.sstart, row.send),
                    "end": max(row.sstart, row.send),
                    "strand": "+" if row.sstart < row.send else "-",
                    "evalue": row.evalue,
                    "bitscore": row.bitscore,
                }
                for row in rows.itertuples(index=False)
            ]

    analyzer = TableAnalyzer(blast_dir=None, output_dir=str(output), min_identity=80)
    # The original pipeline traverses sorted genome IDs. Include every cohort ID,
    # even when it has no tblastn records or no hits passing the original filters.
    analyzer.results_df = pd.DataFrame([
        analyzer.analyze_genome_operon(genome, [genome]) for genome in sorted(cohort)
    ])
    analyzer.results_df.to_csv(output / "operon_order_analysis.csv", index=False)
    counts = analyzer.results_df["operon_type"].value_counts().rename_axis(
        "operon_type"
    ).reset_index(name="genome_count")
    counts["percentage"] = counts["genome_count"] / len(cohort) * 100
    counts.to_csv(output / "operon_organization_counts.csv", index=False)
    analyzer._create_operon_type_chart(analyzer.results_df)
    analyzer._create_gene_order_pdf(analyzer.results_df)
    print(f"Panels A/B: {len(cohort):,} genomes")
    print(counts.to_string(index=False))


def reproduce_c(output):
    """Replot saved operon scores/ranks alongside the top/bottom ten core genes."""
    import matplotlib.pyplot as plt
    import numpy as np
    import pandas as pd

    # Read operon fields as text so the exported table retains their saved values.
    operon = pd.read_csv(
        ROOT / "06_diversity_analysis/output/operon_conservation_summary.csv",
        dtype=str,
    )
    required = ["Gene", "Conservation (%)", "Rank", "Total Core Genes", "Percentile"]
    if not set(required).issubset(operon.columns) or operon[required].isna().any().any():
        raise ValueError("The saved operon summary is missing required fields.")
    if operon["Gene"].duplicated().any() or set(operon["Gene"]) != set(GENE_NAMES):
        raise ValueError("The saved operon summary must contain the seven operon genes.")
    numeric = operon[required[1:]].apply(pd.to_numeric, errors="raise")
    if not np.isfinite(numeric.to_numpy()).all():
        raise ValueError("The saved operon summary contains non-finite numbers.")
    if not numeric["Conservation (%)"].between(0, 100).all():
        raise ValueError("Conservation scores must lie between 0 and 100.")

    core = pd.read_csv(ROOT / "04_core_gene_analysis/output/core_gene_conservation_metrics.csv")
    if core[["gene", "mean_conservation"]].isna().any().any() or core["gene"].duplicated().any():
        raise ValueError("The core-gene table contains missing values or duplicate genes.")
    if not core["mean_conservation"].between(0, 1).all() or len(core) < 20:
        raise ValueError("Expected at least 20 core genes with scores between 0 and 1.")
    core["display_gene"] = core["gene"].str.replace(r"_aligned$", "", regex=True)
    core["Conservation (%)"] = core["mean_conservation"] * 100
    core = core.sort_values("mean_conservation", ascending=False, kind="stable")
    top = core.head(10).copy()
    bottom = core.tail(10).copy()
    top["plot_group"] = "Top 10 core genes"
    bottom["plot_group"] = "Bottom 10 core genes"
    pd.concat([top, bottom]).to_csv(output / "s13c_core_genes.csv", index=False)
    operon["Manuscript gene"] = operon["Gene"].map(GENE_NAMES)
    operon.to_csv(output / "s13c_operon_values.csv", index=False)

    with plt.style.context("default"):
        fig, axes = plt.subplots(1, 3, figsize=(16, 5.6), layout="constrained")
        groups = [
            (top["display_gene"].tolist(), top["Conservation (%)"].to_numpy(),
             "Top 10 core genes", "#408253"),
            (operon["Manuscript gene"].tolist(), numeric["Conservation (%)"].to_numpy(),
             "Fructoselysine operon", "#4c78a8"),
            (bottom["display_gene"].tolist(), bottom["Conservation (%)"].to_numpy(),
             "Bottom 10 core genes", "#a95050"),
        ]
        for index, (axis, (names, values, title, color)) in enumerate(zip(axes, groups)):
            positions = np.arange(len(names))
            axis.barh(positions, values, color=color, height=0.72)
            axis.set_yticks(positions, names)
            axis.invert_yaxis()
            axis.set_xlim(0, 105)
            axis.set_xticks([0, 25, 50, 75, 100])
            axis.set_xlabel("Entropy-derived conservation score (%)")
            axis.set_title(title, pad=14, fontsize=12, fontweight="bold")
            axis.grid(axis="x", color="#dddddd", linewidth=0.6)
            axis.set_axisbelow(True)
            axis.spines[["top", "right"]].set_visible(False)
            for row, value in enumerate(values):
                label = f"{value:.2f}"
                if index == 1:
                    label = f"{operon.iloc[row]['Conservation (%)']}  |  rank {operon.iloc[row]['Rank']}"
                    axis.text(value - 1.5, row, label, ha="right", va="center", color="white", fontsize=9)
                else:
                    axis.text(value - 1.5, row, label, ha="right", va="center", color="white", fontsize=9)
        fig.suptitle("Gene conservation — Fig. S13C source values", fontsize=15)
        for suffix in ("png", "pdf"):
            fig.savefig(output / f"s13c_conservation_ranking.{suffix}", dpi=300, facecolor="white")
        plt.close(fig)
    print("Panel C: replotted saved conservation scores and operon ranks.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--panels", choices=("AB", "C", "all"), default="all")
    parser.add_argument("--output-dir", default=str(ROOT / "reproduced"),
                        help="Output directory (default: codon_muench/reproduced/)")
    args = parser.parse_args()
    panels = ("AB", "C") if args.panels == "all" else (args.panels,)
    try:
        output = check_output_directory(args.output_dir, panels)
    except ValueError as exc:
        parser.error(str(exc))
    # Importing the original module must not create files alongside its source.
    sys.dont_write_bytecode = True
    import matplotlib
    matplotlib.use("Agg")
    output.mkdir(parents=True, exist_ok=True)
    if "AB" in panels:
        reproduce_ab(output)
    if "C" in panels:
        reproduce_c(output)
    print(f"Outputs saved to {output}")


if __name__ == "__main__":
    main()
