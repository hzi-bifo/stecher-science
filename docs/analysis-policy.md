# Manuscript analysis inclusion and corrections

- Include only code, input data and outputs with a verified relationship to a
  reported figure, table or numerical claim. Record shared upstream dependencies
  even when they do not directly draw a figure.
- Distinguish generating a figure from supplying its source data. Record manual
  assembly or experimental imaging as such; do not invent a plotting command.
- For used or possibly used results, compare original and corrected outputs before
  adopting a bug fix. Document immaterial changes; flag substantial changes to the
  affected claim or panel for review. Preserve original inputs and results.
- Preserve defensible methods. Different thresholds or descriptive definitions
  are not automatically bugs. Correct implementation and consistent application
  matter; a preferred alternative method alone does not require a replacement.
- Unused analyses may be removed, or corrected and rerun as clearly labeled
  reference material. This publication branch currently chooses removal. An
  unconfirmed analysis must not be labeled as definitely unused or definitely used.
- Missing input data or unverified provenance must remain explicit. Synthetic
  regression tests alone cannot show that manuscript results are unchanged.
