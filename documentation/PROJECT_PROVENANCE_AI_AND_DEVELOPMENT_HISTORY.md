# Project provenance, artificial-intelligence use, and development history

**Project:** Measurement context in a sequential zebrafish behavioural test battery, with ethanol as a multidomain perturbation
**Author:** Caique Fabris
**Document compiled:** 3 August 2026
**Status:** Single canonical narrative record of the project from origin to release preparation.

## How to read this document

Each statement is marked by evidential basis:

- **[D] Documented** — directly recorded in a log, script, saved output, or Git commit held in this repository.
- **[R] Reconstructed** — inferred from file contents, modification dates, or output structure, with the basis stated.
- **[A] Author-supplied** — provided by the author during manuscript preparation and not independently verifiable from repository artefacts.
- **[U] Unresolved** — not determinable from available evidence.

No event is asserted beyond what these sources support.

---

## 1. Project origin and thesis study

**[D]** The project originates in the author's MSc thesis, *Avaliação da eficácia de baterias de testes comportamentais sequenciais com Danio rerio expostos ao etanol* (Fabris, 2022), held at `references/thesis_fabris, 2022.pdf`. The thesis reports the original experiment in full, including husbandry, apparatus, exposure protocol, endpoint definitions, and the author's original statistical analysis and interpretation.

**[D]** The thesis was conducted at the Laboratório de Ecofisiologia Animal, Universidade Estadual de Londrina, under CEUA/UEL authorisation 040.2020.

**[R]** The present manuscript is a reanalysis and journal adaptation of that single experiment. No new animals were used and no new data were collected at any point in the work recorded here; every dataset in the repository derives from the original thesis experiment.

## 2. Experimental design and original objectives

**[D]** The thesis states the general objective as evaluating the efficacy of applying behavioural tests sequentially in *Danio rerio*, with ethanol used to probe whether a preceding test influences a subsequent one, and with the order of the first two assays reversed to glimpse the effect of assay order.

**[D]** The design crosses three nominal ethanol concentrations (0%, 0.5%, 1%) with three exposure durations (1, 24, 96 h), across three testing contexts:
- **BT1** — the full sequential battery: light–dark test (LDT) → novel tank test (NTT) → swimming-resistance assay;
- **BT2** — reversed behavioural context: NTT → LDT, with no resistance assay;
- **BT3** — isolated endurance context: the resistance assay alone.

**[R]** The manuscript's analytical hierarchy (primary = measurement context; exploratory = cross-endpoint structure; secondary = ethanol responsiveness) was established during manuscript restructuring in 2026 and is documented in `outputs/manuscript/MANUSCRIPT_REORGANIZATION_PLAN.md`. The thesis itself framed battery efficacy as the general objective with ethanol as the investigative tool, so the manuscript hierarchy is consistent with, not a departure from, the original intent.

## 3. Data acquisition and source files

**[D]** The single canonical raw dataset is `data_raw/masters_data.csv`, committed 29 September 2025 (commit `f1b8ac7`, "added masters_data.csv"). It contains 414 records, one per fish, with `battery_suite` identifying context membership.

**[D]** Three additional files, `data_raw/battery_suite_1.csv`, `_2.csv`, and `_3.csv`, were committed in the repository's early history and currently appear as **tracked deletions** in the working tree. Their status is fully analysed in Section 28.

**[D]** `data_raw/masters_data.csv` currently shows as modified in Git. Verification performed 3 August 2026 established that the modification is **line endings only** (LF in `HEAD`, CRLF on disk, consistent with OneDrive/Windows synchronisation). After newline normalisation, the working copy and the committed blob are byte-identical (SHA-256 `bd3af6931733e849dd0e306a…` for both). **Raw data content is unaltered.**

## 4. Data wrangling and processed datasets

**[D]** Wrangling is performed by `notebooks/00_data_wrangling.ipynb` with helper functions in `python/wrangling_helpers.py`. The notebook reads `masters_data.csv` (`RAW_MASTER_PATH`) and writes the per-battery analysis files to `data_processed/`.

**[D]** Outputs: `data_processed/battery_suite_1.csv`, `_2.csv`, `_3.csv` (wrangled, richer schema including `source_row_index`, parse-method fields, and QC flags), and subsequently the audited files `bt1_audited.csv`, `bt2_audited.csv`, `bt3_audited.csv`.

**[D]** Wrangling QC records are in `outputs/logs/wrangling_qc_log.csv`.

## 5. Quality-control and exclusion audit

**[D]** `R/01_data_audit_and_qc.Rmd` performs the audit, producing the `outputs/logs/01_qc_*` family. Four global exclusions are recorded in `outputs/logs/exclusion_log.csv`:
- BT1: one light–dark protocol violation (fish entered the bright zone before the gate was raised) and one death during testing;
- BT2: one fish with entirely missing novel-tank data;
- BT3: one fish with entirely missing endurance data.

**[D]** Analysed samples: 414 raw − 4 = **410 fish**; BT1 = 136, BT2 = 139, BT3 = 135. Per-cell n = 12–16.

**[D]** Endpoint-specific missingness: one no-choice first-choice record in BT1 and one in BT2; blood glucose unavailable for 25 BT1, 102 BT2, and 62 BT3 fish. No values were imputed at any stage.

## 6. Endpoint registry and analytical hierarchy

**[D]** A registry (`outputs/logs/00_endpoint_registry.csv`, `outputs/tables/Table_02_endpoint_registry.csv`) assigns each variable a domain, data type, and analytical role. Fifteen measurements are registered: five LDT (time in bright zone, mean time per crossing, first choice, latency, zone transitions), four NTT (total distance, mean velocity, total movement time, upper-stratum preference), four endurance (resistance index, final flow step, attempts, time at final flow step), plus blood glucose and condition factor.

**[D]** Different analyses use different subsets, deliberately: 13 behavioural/performance endpoints for battery-context comparison (giving 13 × 9 = 117 comparison cells); 14 modelled endpoints for ethanol (the 13 plus blood glucose); 15 endpoints for the correlation analysis; 14 endpoints for the PCA (the 13 plus condition factor, with blood glucose excluded). **[D]** `outputs/logs/02_model_decision_matrix.csv` records condition factor as `not_planned_as_endpoint_model`.

## 7. Statistical pipeline development

**[D]** The pipeline is implemented as R Markdown notebooks `R/00`–`R/11`, each knit to HTML: project setup; data audit and QC; endpoint hierarchy and assumptions; ethanol factorial models; battery-effect analysis; multivariate PCA structure; sensitivity and robustness; reporting tables and figures; statistical methods text; reproducibility audit; manuscript results and discussion; submission-package audit.

**[D]** Model families were assigned from distributional diagnostics recorded in `outputs/logs/02_*` (normality by cell, variance diagnostics, zero-inflation, count overdispersion, binary separation).

## 8. Battery-context analysis

**[D]** `R/04_battery_effect_analysis.Rmd` produces the primary analysis. Comparisons are made within matched treatment × exposure cells, using the correct comparator per endpoint: BT1 vs BT2 for LDT and NTT endpoints, BT1 vs BT3 for endurance endpoints (`outputs/tables/04_comparable_endpoints_retained.csv`, `04_valid_battery_pairs.csv`).

**[D]** Methods: Mann–Whitney rank-sum tests for non-binary endpoints; Fisher's exact test for first choice (verified in `04_battery_adjusted_difference_tests.csv`, field `test_method`); Hedges' *g*, rank-biserial correlation, and Cliff's delta; risk difference and odds ratio for the binary endpoint; percentile bootstrap confidence intervals with 2,000 resamples; Benjamini–Hochberg adjustment across all 117 comparisons.

**[D]** Result: 19 of 117 comparisons showed a BH-adjusted difference; 98 (83.8%) did not. Split: 8 of 81 LDT/NTT, 11 of 36 endurance. Median absolute Hedges' *g* among detected comparisons = 1.16. Effect sizes are oriented as comparison context minus BT1; orientation was verified as internally consistent in all 19 detected rows.

**[D]** Equivalence testing was **not** performed. `outputs/tables/04_battery_tost_equivalence_tests.csv` contains 117 rows all marked "not tested" because no smallest effect size of interest was prespecified. This file is a placeholder and must never be cited as an equivalence result.

## 9. Ethanol endpoint modelling

**[D]** `R/03_ethanol_factorial_models.Rmd` fits treatment × exposure models per endpoint. Governing families: aligned-rank-transform ANOVA for continuous and bounded endpoints; negative-binomial GLM for zone transitions (variance/mean = 12.4); Poisson GLM for attempts (variance/mean = 0.49); Firth penalised logistic regression for first choice (separation); hurdle model for latency; proportional-odds regression for the final flow step.

**[D]** Ten of the fourteen modelled endpoints show at least one BH-adjusted term. Four are null under their governing models: latency, zone transitions, attempts, and time at the final flow step.

## 10. Latency hurdle-model decision

**[D]** Latency is 72.1% zeros (98 of 136 BT1 fish). An initial ART-ANOVA produced a BH-significant treatment × exposure interaction (p_adj = 0.048). A two-part hurdle model was fitted (`outputs/manuscript/19_hurdle_latency_results.md`, 27 June 2026): logistic component for P(latency > 0), log-normal component for log(latency) among the 38 fish with positive latency.

**[D]** Both components are non-significant. The hurdle model is the **governing** analysis; the ART interaction is a zero-inflation artefact and is recorded as superseded. **[D]** The superseded value nonetheless remains present in `outputs/tables/03_ethanol_factorial_results.csv`, which is flagged as a known conflict in `outputs/manuscript/18_canonical_manuscript_brief.md` §15.

## 11. Final-flow proportional-odds model

**[D]** The final flow step (`last_flux`) is an ordered variable with levels 1–12. It was initially fitted with a Poisson GLM, which was misspecified (variance/mean = 1.039 with a bounded ordinal outcome). `R/03_patch_lastflux_polr.R` (27 June 2026) replaced it with proportional-odds logistic regression (MASS::polr, cumulative logit), with type-II likelihood-ratio tests via car::Anova and BH correction within model.

**[D]** Results (`outputs/tables/03_lastflux_polr_results.csv`): treatment χ²(2) = 23.71, p_BH = 2.13 × 10⁻⁵; treatment × exposure χ²(4) = 12.10, p_BH = 0.025; exposure χ²(2) = 4.95, p_BH = 0.084 (not detected).

**[D]** No effect estimates or odds ratios beyond the omnibus tests were saved. The manuscript therefore reports the omnibus statistics only and invents nothing. **[D]** `last_flux` has no dedicated figure and is reported through Table 4; it correlates with the resistance index at ρ ≈ 0.98 and is treated as related, not independent, evidence.

## 12. Post-hoc and CLD correction history

**[D]** `R/03_patch_posthoc_contrasts.R` (30 June 2026) generated the BH-adjusted post-hoc contrasts and compact-letter displays (`outputs/tables/03_ethanol_posthoc_contrasts.csv`, `03_ethanol_cld_letters.csv`).

**[D]** Two localisations were verified directly from the CLD table because they are counter-intuitive and had been misreported in earlier drafts:
- **Mean time per crossing** — 1 h: all three groups distinguished (a/b/c); 24 h: 1% differs from control and 0.5% (a/a/b); 96 h: 0.5% differs from control and 1%, which do not differ from each other (a/b/a).
- **Blood glucose** — 1 h: no pairwise difference (a/a/a); 24 h and 96 h: **the same letters at both durations** (control = ab, 0.5% = a, 1% = b), while the raw mg/dL medians reverse their arrangement between the two durations. An earlier Discussion draft stated that the interaction "direction reversed"; this was corrected in Session 12 after checking the CLD table.

**[D]** CLD letters are on the aligned-rank scale and are reported alongside, never in place of, raw medians.

## 13. Canonical PCA development and version conflict

**[D]** Three mutually inconsistent PCA specifications existed simultaneously in mid-2026:
1. Notebook 05: 13 variables; PC1 = 22.1%, PC2 = 15.7%; included first choice and latency; excluded last flux and time in last flux.
2. `figures_manuscript.R`: a different 13-variable set; PC1 = 23.3%, PC2 = 17.3%; included last flux and time in last flux; excluded first choice and latency.
3. An interim 15-endpoint version including blood glucose: PC1 = 20.2%, PC2 = 15.9%, n = 110.

**[D]** These were consolidated into one canonical PCA (1 August 2026), recorded in `outputs/manuscript/PCA_canonical_report.md` and `PCA_provenance_and_cleanup_log.md`. **[A]** The decisive author instruction was to exclude blood glucose in order to preserve sample size.

**[D]** Canonical specification: BT1; 14 endpoints (blood glucose excluded, condition factor included); complete cases n = 135 of 136 (the single omission is the no-choice first-choice fish); centred and scaled; no imputation; all 14 loading vectors displayed; PC1 = 23.3%, PC2 = 17.2%, cumulative 40.6%; PC3 = 10.3%, reported only in the variance spectrum and never interpreted biologically. Provenance: `outputs/pca_canonical/pca_model_provenance.json`.

**[D]** Because R was unavailable in the analysis environment used for the consolidation, the canonical PCA was computed by a documented prcomp-equivalent SVD (centre = TRUE, scale = TRUE, ddof = 1) in `outputs/manuscript/pca_canonical.py`. All downstream artefacts read the saved canonical scores and loadings; no downstream script refits the PCA.

## 14. Correlation heatmap

**[D]** A Spearman rank-correlation analysis across all 15 registered BT1 endpoints, on pairwise-complete observations (pairwise n = 110–136), was generated 1 August 2026. Outputs: `outputs/tables/FigS6_spearman_correlation_matrix_bt1.csv`, `FigS6_spearman_pvalues_bt1.csv`, `FigS6_pairwise_n_bt1.csv`.

**[D]** Because SciPy was unavailable in that environment, p-values were computed by the large-sample normal approximation to the Spearman *t* statistic. At n ≥ 110 this is accurate, but it is recorded here as a deviation from an exact `cor.test`, and regeneration in R would make the record exact.

**[D]** The analysis deliberately retains blood glucose, which the PCA excludes. This asymmetry is intentional and is stated identically in Methods, Results, and the canonical brief.

## 15. Static figure development and renumbering

**[D]** Manuscript figures were first produced by `outputs/manuscript/figures_manuscript.R` (27 June 2026) in the style of Vieira et al. (2025), rendered 30 June 2026 as PDF and 300-dpi PNG.

**[D]** When the manuscript hierarchy was reorganised to lead with the methodological question, the figure order was renumbered (`outputs/manuscript/figures_final/00_figure_renumbering_map.csv`). Principal changes: the PCA biplot moved from Figure 1 to **Figure 4**; the battery comparison moved from Figure 6 to **Figure 2**; the correlation heatmap moved from supplementary S6 to **Figure 3**; LDT choice moved from main Figure 3 to supplementary **S2**; and supplementary figures shifted by two positions.

**[D]** A new **Figure 1** study-design schematic was created (2 August 2026) and then twice corrected: first because BT2 was drawn as LDT → NTT when the verified order is NTT → LDT, and again for ethanol-timing wording and to remove an unsupported "randomly assigned" claim. Superseded versions are preserved in `outputs/manuscript/archive_figures_superseded/` and the changes are logged in `outputs/manuscript/20_figure_correction_log.md`.

**[D]** Nine figures carry stale text rendered into the image itself; these are catalogued in Section 29 as unresolved.

## 16. Interactive 3D PCA development

**[D]** An interactive PC1–PC2–PC3 visualisation was built with source in `interactive_pca/` (`build_interactive_pca.R`, `preview_server.js`, `README.md`) and a deployable static site in `docs/pca3d/` (`index.html`, `app.js`, `styles.css`, vendored Plotly 3.1.0 with its licence, and `data/` holding the canonical scores, loadings, variance, and provenance JSON).

**[D]** Verified 2 August 2026: `docs/pca3d/data/pca_model_provenance.json` records `n_endpoints = 14` and the same generator as the canonical PCA. The site reads archived canonical values and does not refit the analysis or alter loadings.

**[D]** An earlier standalone file, `outputs/figures/05_pca_interactive_3d_bt1.html` (4.8 MB, from the superseded 13-variable PCA), is obsolete and must not be distributed.

## 17. Manuscript restructuring

**[D]** The manuscript was originally organised around ethanol as the leading result. In 2026 it was reorganised so that measurement context is primary, cross-endpoint structure exploratory, and ethanol secondary (`outputs/manuscript/MANUSCRIPT_REORGANIZATION_PLAN.md`).

**[D]** The reorganisation surfaced a correction of substance: an earlier framing asserted that strong battery-context differences "were not detected". The audited table shows 19 of 117 detected differences concentrated in endurance with large effect sizes, so the conclusion was rewritten to be domain-specific. **[A]** The author approved the domain-specific framing.

**[D]** Two thesis conclusions were not replicated by the factorial reanalysis: `num_changes` and `attempts` were significant in the thesis under uncorrected within-exposure pairwise tests but null under factorial models with BH adjustment. `outputs/manuscript/20_thesis_vs_new_pipeline_conclusions.csv` records the endpoint-by-endpoint reconciliation and directs that the discrepancies be discussed rather than omitted.

## 18. Introduction development

**[D]** The Introduction went through three recorded stages: an initial draft (`23_introduction_draft.md`), a rebalanced version restoring the rodent-to-zebrafish battery history and strengthening the biological rationale for ethanol (`28_introduction_rebalanced.md`), and a final opening correction placing zebrafish first, per the convention of the field, with the rodent-battery history moved to the third paragraph.

**[D]** All 25 citations were verified against the PDFs. **[D]** The thesis's claim of approximately 87% zebrafish–human genetic similarity (attributed to Hung et al., 2012) was **omitted** because that source is not held in `references/` and the figure is easily misread as applying to all human genes. Conservation is described qualitatively via Kalueff et al. (2014).

## 19. Methods harmonisation

**[D]** The Methods were rewritten to be fully self-contained, on the author's instruction that the manuscript is the published record and readers will not have access to the thesis. Procedural detail was recovered from the thesis and translated from Portuguese.

**[D]** Two conflicts were resolved against the audited data rather than the thesis text:
- **Condition factor** — the thesis text states multiplication by 10⁶; the stored operational variable and both audits establish K = 100 × mass(g) / standard length(cm)³ (`outputs/tables/06_condition_factor_audit.csv`: formula correlation 1.0, median absolute difference ≈ 2 × 10⁻¹⁵). The audited definition is used.
- **Battery order** — BT2 was confirmed as NTT → LDT from the thesis and `outputs/logs/01_qc_battery_identity.csv`, correcting an earlier assumption.

**[D]** The swimming-resistance index formula was verified as the sum of completed one-minute flow steps plus the final flow rate weighted by the fraction of the final minute, with the worked example 1+2+…+9 + 10 × (30/60) = 50.

## 20. Results harmonisation

**[D]** The Results were assembled from an architecture document and a 73-row claim-source map (`25_results_architecture.md`, `25_results_claim_source_map.csv`), then harmonised for prose. Every numerical statement was verified against its canonical table.

**[D]** Corrections applied during harmonisation: several adjusted p-values restored to canonical precision; degrees of freedom added to the proportional-odds tests; nine further correlation coefficients added; the latency hurdle bounds quantified; and the discordant `mov_total` control × 24 h cell reported faithfully as a BH-significant rank test whose bootstrap Hedges' *g* interval includes zero.

## 21. Discussion development

**[D]** The Discussion passed through four recorded revisions: an initial version; a thesis-adapted rewrite restoring the author's original reasoning; a rebalancing toward continued battery use and calibration; and a final authorial pass converting third-person "the author" framing to first-person plural.

**[D]** The central interpretive finding is that the detected endurance differences run **opposite** to the anticipated fatigue effect: resistance index and final flow step were lower in the isolated context (BT3) than in the sequential battery (BT1), while attempts were higher. The author's activation/priming hypothesis is retained as the leading explanation because it matches this direction, and is explicitly labelled a hypothesis the design cannot demonstrate.

**[D]** Two claims were qualified in the final pass: a statement that ethanol "progressively overrode" the context effect was reframed as a possible attenuation pattern requiring direct testing; and the glucose "direction reversed" statement was corrected to distinguish identical rank-scale localisation from reversed raw medians.

**[D]** Rosemberg et al. (2012) was re-scoped after PDF inspection: it tests acute 1% ethanol at 20 and 60 min, so it now supports acute short-timescale reversal, while Mathur and Guo (2011) and Tran and Gerlai (2013) carry the acute-versus-prolonged contrast.

## 22. Final figure packaging

**[D]** On 3 August 2026, 15 figures (8 main, 7 supplementary) were copied in both PDF and PNG from the sole canonical source `outputs/manuscript/figures_final/` into `final_manuscript/figures/`. All 30 source/destination SHA-256 pairs match; integrity was re-verified during this session with zero failures. Deliverables accompany the figures: `figure_manifest.csv`, `figure_audit.md`, `figure_captions.md`, and `interactive_pca_location.txt`.

**[D]** No figure was regenerated, edited, resized, relabelled, or recompressed at any point in packaging.

## 23. Final manuscript audit

**[D]** Performed 3 August 2026 across the four final text sources. Confirmed consistent: the three-level question hierarchy; battery terminology; endpoint accounting (15 registered / 13 context / 117 cells / 14 ethanol-modelled / 15 correlation / 14 PCA); sample sizes (410; 136/139/135); primary results (98 of 117 at 83.8%, 19 detected, 8 of 81, 11 of 36, median |*g*| = 1.16); the PCA specification; the ethanol counts; the IRN formula and worked example; and all 15 figure references against the manifest.

**[D]** Confirmed absent: any equivalence claim, any "inconclusive" verdict, any description of BT2 as isolated, any citation in Methods or Results other than the Lakens equivalence framework, and any biological interpretation of PC3.

**[D]** One residual issue found: PCA variance percentages appear in Methods §2.9.6, where they are Results findings (Section 29).

## 24. Artificial-intelligence use

**[A]** Two systems were used during preparation of this work:
- **OpenAI GPT Codex Sol 5.6**, High setting
- **Anthropic Claude Code Opus 5.0**, High setting

**[D]** They assisted with:
- manuscript architecture and section hierarchy;
- drafting and language revision of all manuscript sections;
- inspection of analysis code and identification of model misspecification;
- debugging and the writing of correction scripts;
- consistency checking among scripts, saved outputs, tables, figures, and manuscript text;
- literature organisation and verification of citations against source PDFs;
- figure and table auditing, including renumbering and provenance tracking;
- provenance documentation, including this document;
- design of the GitHub release structure.

**[D]** Concrete examples of AI-assisted findings that changed the manuscript, each verified by the author against saved outputs before acceptance: identification of the misspecified Poisson model for the ordinal final flow step; identification of the latency zero-inflation artefact; detection of three mutually inconsistent PCA specifications; detection that the TOST table contained only placeholders and could not support an equivalence claim; detection that the Figure 1 schematic drew BT2 in the wrong order; and detection that `4_discussion.pdf` is a duplicate of the Results.

**Statement of limits.** The AI systems did not become authors and hold no authorship. They did not generate raw observations, determine the experimental design, or assume scientific responsibility. Their use was **not** limited to grammar correction; they participated substantively in analysis inspection, documentation, and drafting, which is the reason this disclosure is detailed.

## 25. Human oversight and responsibility

**[A]** All AI-assisted material was reviewed by the human author against the original data, the saved analysis outputs, the analysis code, the thesis, and the source literature. No statistical result, citation, or endpoint definition was accepted solely from model-generated text.

**[A]** Final scientific, methodological, statistical, interpretive, and editorial decisions remained with the human author, who approved the manuscript and accepts full responsibility for its accuracy, integrity, and originality.

**[D]** Decision points where the author overrode or directed the analysis are recorded in the session logs, including: the exclusion of blood glucose from the PCA to preserve sample size; the domain-specific framing of the primary conclusion; the instruction that the Methods be fully self-contained; the decision to retain all registered endpoints in the exploratory visualisation despite redundancy; and the requirement that the Introduction open with zebrafish rather than rodent batteries.

## 26. Files retained in the final release

Manuscript text (Markdown and LaTeX for Introduction, Methods, Results, Discussion, Abstract); the 30 final figure files with manifest, audit, and captions; raw data (`masters_data.csv`); processed and audited datasets; all R, Python, and notebook source; canonical statistical tables; model objects; canonical PCA artefacts; reproducibility records; the interactive PCA source and deployable site; and this provenance document. Full structure in `github_release/`.

## 27. Files excluded from the release

**Reference PDFs.** `references/` holds 43 copyrighted articles (59 MB). These are third-party publisher content and are **not** redistributable on a public repository. The release includes `references/README.md` listing the citations with DOIs so that readers can obtain them legitimately.

**Editor and session artefacts.** `.Rproj.user/`, `.Rhistory`, `.RDataTmp`, `__pycache__/`.

**Superseded intermediate outputs.** Detailed in Section 28; these are excluded from the release but **not** deleted from the working repository without separate authorisation.

## 28. Files proposed for deletion

**No deletion has been performed.** This section is a proposal requiring explicit authorisation.

### 28.1 The deleted raw-data files — recommendation: RESTORE, do not delete

`data_raw/battery_suite_1.csv`, `_2.csv`, `_3.csv` currently appear as tracked deletions. Investigation on 3 August 2026 established:

| Property | Finding |
|---|---|
| Recoverable from Git | **Yes** — all three present in `HEAD` |
| Blob hashes / sizes | `120c07f6b787` 29,543 b; `07ceda02f944` 26,597 b; `4b64f51bcc40` 11,551 b |
| Content SHA-256 | `3fa40d214c98a062…`, `39c4abe47bac72a6…`, `7a3b924c48c4bdcd…` |
| Schema | Simple per-battery split (fish_id, group, treatment, exposure, datetime, endpoints) |
| Relationship to `data_processed/battery_suite_*.csv` | **Different files** — the processed versions are larger (67/65/37 kB) with an audited schema |
| Code dependency | **None.** All 14 code references point to `data_processed/`; the wrangling notebook reads `masters_data.csv` and *writes* the processed files |
| Deletion documented? | **No** — no log or commit message explains it |

**[R]** These appear to be early intermediate per-battery splits, superseded by the notebook-generated `data_processed/` files. **[U]** Whether the deletion was intentional is not documented.

**Recommendation:** because they sit under `data_raw/` and the preservation rule is absolute, **restore them from Git** (`git checkout HEAD -- data_raw/battery_suite_*.csv`) and retain them, or, if they are confirmed derived rather than raw, move them to an `archive/` path with a note. **Do not delete.** No action taken in this session.

### 28.2 Safe deletion candidates (require authorisation)

| Category | Paths | Rationale |
|---|---|---|
| Editor state | `.Rproj.user/`, `R/.Rproj.user/`, `R/.Rhistory`, `.Rhistory` | IDE session state, no scientific content |
| Temporary R data | `.RDataTmp` (3.5 MB) | Transient workspace dump |
| Python bytecode | `python/__pycache__/` | Regenerable |
| Obsolete interactive PCA | `outputs/figures/05_pca_interactive_3d_bt1.html` (4.8 MB) | Superseded 13-variable PCA; replaced by `docs/pca3d/` |
| Legacy PCA outputs | `outputs/tables/05_pca_*`, `outputs/figures/05_pca_*` | Superseded by `outputs/pca_canonical/`; **retain as provenance unless space is critical** |
| Superseded figure sets | `outputs/manuscript/figures/` (pre-renumbering) | Canonical set is `figures_final/`; superseded Figure 1 versions already archived |
| Empty directory | `archive/` (0 bytes) | Empty |

**Explicitly protected from any deletion:** `.git/`, `data_raw/`, `data_processed/`, `R/`, `python/`, `notebooks/`, `outputs/tables/`, `outputs/models/`, `outputs/pca_canonical/`, `outputs/reproducibility/`, `outputs/logs/`, `final_manuscript/`, `interactive_pca/`, `docs/`, `references/`, and this document.

## 29. Unresolved matters

1. **`4_discussion.pdf` is not the Discussion.** It is a byte-identical duplicate of `3_results.pdf` (both SHA-256 `c05aed0e9c357785…`). The Discussion is absent from `final_manuscript/manuscript/`. **Release blocker.** The correct source is `outputs/manuscript/31_discussion_harmonised_overleaf.tex`; no replacement was fabricated.

2. **Nine figures carry stale text rendered into the image.** Six are cosmetic obsolete numbering (Figure 3 titled "Figure S6"; Figure 4 titled "Figure 1"; S3–S7 titled "S1."–"S5."). Two are substantive: **Figure S1** is titled "canonical 15-endpoint BT1 PCA" while correctly plotting 14 components, and **Figure 2**'s legend reads "Isolated (BT2)" when BT2 is the reversed behavioural context. Both should be regenerated before submission.

3. **PCA variance percentages appear in Methods §2.9.6** (23.3%, 17.2%, 40.6%, 10.3%). These are Results findings; recommended surgical correction is to state the procedure in Methods and leave the percentages to Results and captions.

4. **Superseded latency value in a canonical table.** `03_ethanol_factorial_results.csv` still contains the BH-significant ART latency interaction (p_adj = 0.048) superseded by the hurdle model. Any Table 4 export must annotate it.

5. **Author confirmations outstanding (ARRIVE).** Randomisation procedure, scorer blinding, and number of experimental batches are not documented in the available records. Not asserted either way in the manuscript.

6. **Bibliographic completeness.** Volume, page, or DOI fields remain to be filled for several references. No field was invented.

7. **Target journal not fixed.** Abstract length (292 words) and reference formatting remain provisional.

8. **Correlation p-values by normal approximation.** Accurate at n ≥ 110 but not exact; regeneration in R with `cor.test` would make the record exact.

## 30. Final reproducibility status

**[D]** Software: analyses in R 4.5.3; data preparation in Python. Principal packages with recorded versions: ARTool 0.11.2, emmeans 2.0.2, car 3.1-5, boot 1.3-32, factoextra 2.0.0; MASS and logistf used without recorded version numbers. Session information in `outputs/reproducibility/09_session_info.txt`.

**[D]** The chain from raw data to manuscript claim is traceable end to end: `masters_data.csv` → `notebooks/00_data_wrangling.ipynb` → `data_processed/` → `R/01`–`R/11` plus the two patch scripts → `outputs/tables/`, `outputs/models/`, `outputs/pca_canonical/` → `25_results_claim_source_map.csv` (73 mapped claims) → manuscript sections → `final_manuscript/figures/` (30 hash-verified files).

**[D]** Deviations from a pure R pipeline, both documented above: the canonical PCA was computed by a prcomp-equivalent SVD in Python because R was unavailable in the consolidation environment, and Spearman p-values were computed by normal approximation because SciPy was unavailable.

**[D]** Raw data integrity confirmed on 3 August 2026: `masters_data.csv` differs from its committed version by line endings only, with identical content after normalisation.

**Overall status:** the analysis is complete, internally consistent, and traceable. The manuscript is submission-ready in text and figures, subject to the eight unresolved matters in Section 29, of which item 1 (the missing Discussion PDF) and item 2 (two substantive figure labels) are the only ones that block submission.

---

# Appendix — consolidated file history

## A. Canonical files created

**Manuscript text:** `28_introduction_rebalanced.md/.tex`; `29_methods_harmonised.md/.tex`; `30_results_harmonised.md/.tex`; `31_discussion_harmonised.md/.tex`; `32_abstract.md/.tex`.

**Evidence and control:** `18_canonical_manuscript_brief.md`; `18_figure_evidence_map.md`; `19_methods_extraction_log.md`; `20_final_figure_captions.md`; `20_figure_correction_log.md`; `25_results_architecture.md`; `25_results_claim_source_map.csv`; `PCA_canonical_report.md`; `PCA_provenance_and_cleanup_log.md`; `MANUSCRIPT_REORGANIZATION_PLAN.md`.

**Harmonisation and evidence logs:** `29_methods_harmonisation_log.md`; `30_results_harmonisation_log.md`; `31_discussion_harmonisation_log.md`; `31_discussion_evidence_log.md`; `23_literature_evidence_log.md`; `28_introduction_rebalanced_evidence_log.md`; `27_introduction_evidence_log.md`; `32_abstract_log.md`; `21_primary_results_evidence_log.md`; `22_exploratory_secondary_results_evidence_log.md`.

**Analysis artefacts:** `outputs/pca_canonical/` (analysis dataset, complete-case record, scaling summary, variance, loadings, scores, provenance JSON); `outputs/tables/FigS6_spearman_*`; `outputs/manuscript/pca_canonical.py`; `pca_figures.py`.

**Figures:** `outputs/manuscript/figures_final/` (30 files + renumbering map); `final_manuscript/figures/` (30 files + 4 deliverables).

**Interactive:** `interactive_pca/`; `docs/pca3d/`.

**This document:** `final_manuscript/PROJECT_PROVENANCE_AI_AND_DEVELOPMENT_HISTORY.md`.

## B. Canonical files modified

`outputs/tables/03_lastflux_polr_results.csv` (created by patch, replacing the Poisson result); `03_ethanol_posthoc_contrasts.csv` and `03_ethanol_cld_letters.csv` (created by post-hoc patch); `18_canonical_manuscript_brief.md` and `18_figure_evidence_map.md` (corrected across sessions for encoding, endpoint counts, condition-factor provenance, PCA dimensionality, and figure status); `26_integrated_results.md/.tex` (single authorised terminology correction, "14 registered" → "14 modelled" in the ethanol overview only).

## C. Superseded drafts (retained as provenance)

`10_*` manuscript drafts; `12_*` blueprints and advisor tables; `draft_results_section.md`; `draft_results_v2.md`; `21_pipeline_audit_and_rerun_plan.md`; `23_introduction_draft.md`; `27_introduction_*` (superseded by 28); `24_discussion_draft.md` (superseded by 31); `26_integrated_results.*` (superseded by 30); `MANUSCRIPT_DRAFT_v3_reorganized.md`; `00_READINESS_MAP.md`.

## D. Correction scripts

`R/03_patch_lastflux_polr.R` — Poisson → proportional-odds for the ordinal final flow step.
`R/03_patch_posthoc_contrasts.R` — BH-adjusted post-hoc contrasts and compact-letter displays.

## E. Figure versions

Original set (`figures_manuscript.R`, 30 June 2026) → renumbered canonical set (`figures_final/`, 2 August 2026) → packaged release set (`final_manuscript/figures/`, 3 August 2026). Superseded Figure 1 versions preserved in `outputs/manuscript/archive_figures_superseded/` with `SUPERSEDED_wrong_BT2_order` and `SUPERSEDED_session3_wording` suffixes.

## F. Logs consolidated into this document

All session-level harmonisation, correction, evidence, and provenance logs listed in Appendix A. They remain individually on disk; this document is the single narrative record.

## G. Proposed deletions

See Section 28. Nothing deleted in this session.

## H. Preserved data and code

`data_raw/masters_data.csv`; `data_processed/` (6 files); `R/` (12 notebooks, 2 patch scripts, knit HTML); `python/wrangling_helpers.py`; `notebooks/00_data_wrangling.ipynb`; `outputs/tables/`; `outputs/models/`; `outputs/logs/`; `outputs/pca_canonical/`; `outputs/reproducibility/`; `references/thesis_fabris, 2022.pdf`.

## I. Current unexplained Git changes

| Path | Git status | Assessment |
|---|---|---|
| `data_raw/battery_suite_1/2/3.csv` | deleted | **Unexplained.** Recoverable from Git; no code dependency; recommend restore (Section 28.1) |
| `data_raw/masters_data.csv` | modified | **Explained.** Line endings only (LF → CRLF); content identical after normalisation |
| `.gitignore` | modified | Expected — updated during release preparation |
| `R/00_project_setup.Rmd` | modified | Expected — pipeline development |
| `notebooks/00_data_wrangling.ipynb` | modified | Expected — pipeline development |
| `data_processed/`, `docs/`, `R/` notebooks and outputs, `AGENTS.md`, editor artefacts | untracked | Expected — generated after the last commit (6 April 2026); the repository has only 8 commits and most 2026 work is uncommitted |

**[R]** The repository's last commit predates almost all of the 2026 analysis and manuscript work. Committing the current state is recommended before or as part of the release, so that the provenance recorded here is captured in version control.
