# Measurement context in a sequential zebrafish behavioural test battery

Reanalysis and manuscript materials for a study of how **measurement context** affects behavioural endpoints when assays are administered in a sequential battery, using ethanol as a secondary multidomain perturbation.

Adult zebrafish (*Danio rerio*) completed a light–dark test (LDT), a novel tank test (NTT), and a swimming-resistance assay. Each measurement was compared against a context in which the assay occupied a different position.

## The question

An assay placed inside a sequence may measure something subtly different from the same assay performed first. This repository holds the data, code, and manuscript for an endpoint-by-endpoint estimate of that difference.

**Headline result.** Across 117 endpoint-by-treatment-by-exposure comparisons, 98 (83.8%) showed no detected Benjamini–Hochberg-adjusted context difference. The 19 detected differences were concentrated in the endurance domain (11 of 36) and were large (median absolute Hedges' *g* = 1.16). Interference was therefore selective rather than pervasive.

Formal equivalence was **not** tested: no endpoint-specific equivalence margins were prespecified, so no comparison should be read as demonstrating interchangeability.

## Testing contexts

| Context | Sequence | n |
|---|---|---|
| **BT1** | LDT → NTT → swimming resistance | 136 |
| **BT2** | NTT → LDT (no resistance assay) | 139 |
| **BT3** | Swimming resistance alone | 135 |

An assay performed first has no preceding behavioural test and is *isolated* with respect to prior behavioural testing; an assay performed second is *sequential*. The LDT is isolated in BT1 and sequential in BT2; the NTT is isolated in BT2 and sequential in BT1; resistance is sequential in BT1 and isolated as an entire session in BT3. Because different fish were tested in each context, all comparisons are **between groups**.

## Design

3 × 3 factorial: ethanol at 0% (control), 0.5%, and 1%, crossed with exposure durations of 1, 24, and 96 h. Total analysed: **410 fish** (414 raw, 4 global exclusions).

## Repository layout

```
manuscript/
  sections/     Abstract, Introduction, Methods, Results, Discussion (Markdown) + figure captions
  source/       Matching LaTeX sources (authoritative for mathematical symbols)
  figures/      30 final figure files (8 main + 7 supplementary, PDF and PNG) + manifest, audit, captions
data/
  raw/          masters_data.csv — the single canonical raw dataset
  processed/    Wrangled and audited analysis-ready datasets
code/
  R/            Analysis pipeline (00–11) plus two correction scripts
  python/       Wrangling helpers
  notebooks/    Data-wrangling notebook
outputs/
  tables/       Canonical statistical tables
  models/       Saved model objects
  pca_canonical/  The single canonical PCA (scores, loadings, variance, provenance)
  reproducibility/  Session information and package versions
  logs/         QC, exclusion, and audit records
interactive_pca/
  source/       Build system for the interactive 3D PCA
  site/         Deployable static site (reads the canonical PCA; does not refit)
documentation/
  PROJECT_PROVENANCE_AI_AND_DEVELOPMENT_HISTORY.md  ← start here for full history
references/
  README.md     Citation list with DOIs (PDFs not redistributed — copyright)
```

## Reproducing the analysis

1. `code/notebooks/00_data_wrangling.ipynb` reads `data/raw/masters_data.csv` and writes `data/processed/`.
2. `code/R/00`–`11` run the pipeline: QC, assumptions, ethanol factorial models, battery-context analysis, PCA, robustness, reporting.
3. `code/R/03_patch_lastflux_polr.R` and `03_patch_posthoc_contrasts.R` apply two model corrections (see below).
4. Canonical outputs land in `outputs/`.

Software: R 4.5.3 with ARTool 0.11.2, emmeans 2.0.2, car 3.1-5, boot 1.3-32, factoextra 2.0.0, MASS, logistf; Python for wrangling. Full session information in `outputs/reproducibility/`.

**Two documented deviations.** The canonical PCA was computed by a prcomp-equivalent SVD in Python because R was unavailable in the consolidation environment, and Spearman p-values used a large-sample normal approximation because SciPy was unavailable. Both are recorded in the provenance document; regeneration in R would make the record exact.

## Statistical approach

Battery-context comparisons use Mann–Whitney tests within matched treatment × exposure cells (Fisher's exact test for the binary first-choice endpoint), with Hedges' *g*, rank-biserial correlation, Cliff's delta, and 2,000-resample bootstrap confidence intervals, Benjamini–Hochberg adjusted across all 117 comparisons. Effect sizes are oriented as **comparison context minus BT1**.

Ethanol models are matched to each endpoint's measurement scale: aligned-rank-transform ANOVA for continuous and bounded endpoints, negative-binomial for zone transitions, Poisson for attempts, Firth penalised logistic regression for first choice, a two-part hurdle model for the zero-inflated latency, and proportional-odds regression for the ordinal final flow step.

Correlation and PCA are exploratory and descriptive. They are not used to test ethanol or context effects, and no treatment-group separation is inferred from component scores.

## Known issues before submission

See `documentation/PROJECT_PROVENANCE_AI_AND_DEVELOPMENT_HISTORY.md` §29. The two that block submission:

1. The compiled Discussion PDF in the private working repository is a duplicate of the Results and must be regenerated from `manuscript/source/31_discussion_harmonised_overleaf.tex`.
2. Two figures carry stale text rendered into the image: Figure S1 is titled "15-endpoint" while correctly plotting 14 components, and Figure 2's legend reads "Isolated (BT2)" when BT2 is the reversed behavioural context.

## Use of artificial intelligence

AI systems (OpenAI GPT Codex Sol 5.6, High setting; Anthropic Claude Code Opus 5.0, High setting) assisted with manuscript architecture, drafting and language revision, code inspection and debugging, consistency checking, literature organisation, figure and table auditing, provenance documentation, and the design of this release. Their use was **not** limited to grammar correction.

All AI-assisted material was reviewed by the human author against the original data, saved analyses, code, thesis, and source literature. No statistical result, citation, or endpoint definition was accepted solely from model-generated text. The AI systems are not authors and hold no scientific responsibility. Final scientific, statistical, interpretive, and editorial decisions remained with the human author, who accepts full responsibility for the work. Full disclosure in the provenance document, §24–25.

## Citation

Fabris, C. (2026). *Measurement context in a sequential zebrafish behavioural test battery.* Manuscript in preparation. Based on the MSc thesis: Fabris, C. (2022), Universidade Estadual de Londrina.

## Ethics

All procedures were approved by the Animal Use Ethics Committee of the State University of Londrina (CEUA/UEL), authorisation 040.2020. No new animals were used in this reanalysis.
