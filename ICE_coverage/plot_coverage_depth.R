# Fig. S9C: coverage of the ICE region in E. faecalis isolates
# (reads mapped to the B. coccoides reference genome)
#
# Input:  per-position depth files (*.depth), one per sample, with three
#         tab-separated columns: contig, position, depth.
#         The sample name is taken from the file name (text before the first ".").
# Output: faceted coverage plot (PNG and SVG) in `out_dir`.

library(ggplot2)
library(dplyr)
library(forcats)
library(stringr)
library(RColorBrewer)
library(ragg)  # faster PNG rendering

# ---- Parameters -------------------------------------------------------------
depth_dir    <- "depth_files"   # folder containing the *.depth files
out_dir      <- "plots"
region_start <- 2100000
region_end   <- 2500000

# Samples to plot, in the order they appear from top to bottom
sample_order <- c("SW278", "SW269", "SW293", "SW295", "KB1", "SW160", "SW178")

sample_colors <- c(
  SW160 = "#ee0d6c",
  SW293 = "#7ccba2",
  SW295 = "#7ccba2",
  SW269 = "#4a6a8e",
  SW278 = "#4a6a8e",
  SW178 = "#7c1d6f",
  KB1   = "#0B8C86"
)

# ---- Read depth files -------------------------------------------------------
file_paths <- list.files(depth_dir, pattern = "\\.depth$",
                         full.names = TRUE, recursive = TRUE)

depth_data <- lapply(file_paths, function(file) {
  df <- read.table(file, header = FALSE,
                   col.names = c("contig", "position", "depth"))
  df$sample <- str_extract(basename(file), "^[^\\.]+")
  df
}) %>%
  bind_rows() %>%
  filter(position >= region_start, position <= region_end,
         sample %in% sample_order) %>%
  mutate(sample = factor(sample, levels = sample_order))

# ---- Plot -------------------------------------------------------------------
p <- ggplot(depth_data, aes(x = position, y = depth, colour = sample)) +
  geom_col() +
  facet_wrap(~ sample, scales = "free_y", ncol = 1) +
  geom_hline(yintercept = 0, colour = "gray70", linewidth = 0.5) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  scale_colour_manual(values = sample_colors) +
  labs(
    title = "Read Coverage over Operon - Faceted by Sample",
    x = "Position on Operon",
    y = "Depth of Coverage"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    strip.text = element_text(size = 10, face = "bold"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 14, face = "bold"),
    panel.grid.major = element_blank(),
    plot.background = element_rect(fill = "white", colour = NA),
    panel.background = element_rect(fill = "white", colour = NA)
  )

# ---- Save -------------------------------------------------------------------
dir.create(out_dir, showWarnings = FALSE)
ggsave(file.path(out_dir, "coverage_depth.png"), plot = p,
       device = ragg::agg_png, width = 16, height = 10, units = "in")
ggsave(file.path(out_dir, "coverage_depth.svg"), plot = p,
       width = 10, height = 8, units = "in")
