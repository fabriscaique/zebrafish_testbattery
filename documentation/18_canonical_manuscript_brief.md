# 18 - Canonical Manuscript Brief (SESSION 1 LOCK; Session 2 corrected)

**Correction date:** 2026-08-02 (Session 2).
**Corrections applied:** (1) encoding normalized to plain UTF-8/ASCII; (2) endpoint count corrected - blood_sugar is a modelled ethanol endpoint (14th), condition_factor is a separate 15th control endpoint and is NOT counted among the 14; (3) condition-factor provenance resolved - no canonical inferential model exists, so it is descriptive/control only; (4) PCA manuscript visualization locked to PC1-PC2 only (PC3 not interpreted); (5) heatmap/PCA asymmetry preserved.

**Status:** Evidence base locked. No analyses rerun; no data/models/figures/tables modified. Values verified against canonical audited tables (sources cited). Conflicts are documented in Section 15, not silently resolved.

---

## 1. Manuscript identity
A methodology-led study of a sequential zebrafish (Danio rerio) behavioural test battery (BT1: LDT -> NTT -> resistance), using ethanol (0/0.5/1% x 1/24/96 h) as a secondary multidomain perturbation, with exploratory correlation and PCA to characterize - not validate - endpoint structure. The manuscript is self-contained (it replaces the thesis as the published record); readers are never referred to the thesis.

## 2. Inferential hierarchy (locked)
1. Primary (methodological): Do measurements differ when assays are administered sequentially (BT1) vs in isolated contexts (BT2 for LDT/NTT; BT3 for endurance)?
2. Secondary (pharmacological): Which BT1 endpoints respond to ethanol concentration, exposure duration, or their interaction?
3. Exploratory (multivariate): How are endpoints related across domains (correlation, PCA)?
4. Future: Can a counterbalanced, adequately powered study establish practical equivalence for selected endpoints?

## 3. Claims permitted
- Report detected context differences as context sensitivity, by endpoint and cell, with effect sizes and CIs.
- State that context differences were concentrated in resistance/endurance measurements.
- State that most LDT and NTT comparisons showed no BH-adjusted context difference.
- Report ethanol effects as endpoint- and duration-dependent within BT1.
- Describe correlation/PCA structure descriptively.

## 4. Claims prohibited
- Do NOT call the battery "validated" or measurements "equivalent"/"interchangeable".
- Do NOT interpret non-detection as equivalence.
- Do NOT causally attribute context differences to fatigue, carry-over, cumulative stress, elapsed time, or order (design cannot separate these).
- Do NOT call any endpoint a "primary endpoint" (no prespecified hypothesis hierarchy).
- Do NOT treat correlated endpoints (e.g., resistance_index and last_flux) as independent confirmation.
- Do NOT claim treatment separation from the PCA.
- Do NOT use retrospective TOST labels (equivalent / non-equivalent / inconclusive-under-TOST).
- Do NOT interpret PC3 in the main manuscript.

## 5. Canonical sample and design facts (verified)
- Batteries: BT1 full sequential (LDT+NTT+endurance; n=136), BT2 alternative LDT/NTT context (LDT+NTT, no endurance; n=139), BT3 isolated endurance (endurance only; n=135). Source: logs/01_qc_battery_identity.csv.
- Global exclusions (4 total): BT1 = 138 raw minus 2 (1 LDT protocol violation, 1 death) = 136; BT2 = 140 minus 1 (all novel-tank data missing) = 139; BT3 = 136 minus 1 (all endurance data missing) = 135. Raw total 414; analyzed 410. Source: outputs/logs/exclusion_log.csv.
- One row per fish. Per-cell n = 12-16. In BT1: 1 no-choice first-choice (missing for that endpoint); blood glucose missing for 25 fish; all other endpoints complete.
- Factorial: outcome ~ treatment (0/0.5/1%) x exposure (1/24/96 h).

## 6. Primary battery-context findings (verified - tables/04_battery_adjusted_difference_tests.csv)
- 117 matched endpoint x cell comparisons; 19 (16.2%) BH-adjusted differences detected (98 not detected).
- BT1 vs BT2 (LDT/NTT): 8/81 detected. BT1 vs BT3 (endurance): 11/36 detected.
- Detected endpoints (cells; Hedges g range; direction b=isolated minus a=BT1):
  - BT1 vs BT2: time_bright (1; g approx 1.10; iso>BT1), mtpc (1; g approx 0.64; iso>BT1), dist_total (1; g approx 1.14; iso>BT1), vel_mean (2; g approx 1.10-1.15; iso>BT1), mov_total (2; g approx -0.75 to -0.58; iso<BT1), stratum_pref (1; g approx 1.94; iso>BT1).
  - BT1 vs BT3: resistance_index (4; g approx -1.68 to -1.16; iso<BT1), last_flux (4; g approx -1.36 to -0.97; iso<BT1), attempts (2; g approx 0.89-1.37; iso>BT1), time_in_last_flux (1; g approx -1.34; iso<BT1).
- Where detected, effects were large (|g| median approx 1.16, up to approx 1.94). Direction split: 11 iso<BT1, 8 iso>BT1.
- Effect-size types: Hedges g, rank-biserial, Cliff's delta (continuous/derived); risk difference and odds ratio (binary first_choice). CI source: tables/04_battery_bootstrap_confidence_intervals.csv. Adjusted p: p_value_bh in the adjusted-difference table.
- Comparators (locked): LDT (time_bright, mtpc, first_choice_binary, latency, num_changes) and NTT (dist_total, vel_mean, mov_total, stratum_pref) -> BT1 vs BT2; endurance (resistance_index, last_flux, attempts, time_in_last_flux) -> BT1 vs BT3. Source: tables/04_comparable_endpoints_retained.csv.
- No isolated comparator: blood_sugar and condition_factor (Kc) are absent from the comparable set, so they have NO battery-context comparison and enter only the ethanol/exploratory analyses.
- Effect sizes are NOT displayed in the battery-context figure (Fig 2 is boxplots only); they live in Table 3. A Hedges g forest plot exists (outputs/figures/04_battery_hedges_g_forest_plot.png) but is not in the manuscript figure set.

## 7. Secondary ethanol endpoint registry (verified)
Sources: tables/03_ethanol_factorial_results.csv, 03_lastflux_polr_results.csv, 03_ethanol_cld_letters.csv, manuscript/19_hurdle_latency_results.md.

There are 14 modelled ethanol endpoints. blood_sugar is the 14th. condition_factor is a separate 15th REGISTERED CONTROL endpoint and is NOT a modelled ethanol endpoint (Section 7a).

| # | Endpoint | Domain | Governing model family | BH-significant term(s) | Status |
|---|---|---|---|---|---|
| 1 | time_bright | LDT | ART-ANOVA | treatment; exposure | effect |
| 2 | mtpc | LDT | ART-ANOVA | treatment; exposure; treatment:exposure | effect |
| 3 | first_choice_binary | LDT | Firth logistic | trt0.5:24h, trt1:24h, trt0.5:96h, trt1:96h (coefficient-level) | effect |
| 4 | latency | LDT | hurdle (governing); ART superseded | hurdle: none | null (ART interaction p_adj=0.048 SUPERSEDED) |
| 5 | num_changes | LDT | negative-binomial GLM | none | null |
| 6 | dist_total | NTT | ART-ANOVA | treatment:exposure | effect |
| 7 | vel_mean | NTT | ART-ANOVA | treatment:exposure | effect |
| 8 | mov_total | NTT | ART-ANOVA | treatment:exposure | effect |
| 9 | stratum_pref | NTT | ART-ANOVA | treatment (omnibus only; NO significant pairwise contrast) | effect (omnibus) |
| 10 | resistance_index | RN | ART-ANOVA | treatment; exposure (interaction marginal p_adj approx 0.054) | effect |
| 11 | last_flux | RN | proportional-odds (polr) | treatment; treatment:exposure | effect |
| 12 | attempts | RN | Poisson GLM | none | null |
| 13 | time_in_last_flux | RN | ART-ANOVA | none | null |
| 14 | blood_sugar | Physiology | ART-ANOVA | exposure; treatment:exposure | effect |

- Modelled endpoints = 14. After applying the governing hurdle rule to latency: 10 of 14 show at least one genuine BH-significant treatment/exposure/interaction/coefficient term; 4 null (latency, num_changes, attempts, time_in_last_flux).
- The raw factorial table would count 11 because latency's ART interaction is flagged but superseded by the hurdle-null.
- ART inference is rank-based; localization only via BH-adjusted contrasts and CLD.
- first_choice_binary is NOT "null": it has significant 24 h and 96 h coefficient-level interaction terms.

### 7a. Condition factor (Kc) - separate control endpoint (provenance resolved)
condition_factor is the 15th registered endpoint, classified in the pipeline as "not_planned_as_endpoint_model" (logs/02_model_decision_matrix.csv; 03_ethanol_model_skipped_registry_rows.csv). No condition-factor row exists in any ethanol model, CLD, or post-hoc table. Therefore NO canonical inferential result exists. Condition factor is DESCRIPTIVE/CONTROL only. Any "ART-ANOVA, all terms non-significant" statement (e.g., the FigS7 caption) is UNSUPPORTED and must be removed; FigS7 requires a descriptive-only caption.

### 7b. CLD checks (verified from tables/03_ethanol_cld_letters.csv)
- MTPC: 1h a/b/c (all differ); 24h a/a/b (1% differs from CTR and 0.5%); 96h a/b/a (0.5% differs from CTR and 1%; CTR and 1% do NOT differ).
- Blood glucose (describe from the CLD table, not medians; interaction reverses direction): 1h a/a/a (no difference); 24h CTR=ab, 0.5%=a, 1%=b with 1% HIGHEST; 96h CTR=ab, 0.5%=a (HIGHEST), 1%=b (LOWEST). The "b" group is highest at 24h but lowest at 96h. Note: CLD emmeans are on the aligned-rank scale, not mg/dL; report raw mg/dL medians from the descriptive table.

## 8. Exploratory correlation specification (locked)
"The pairwise-complete Spearman correlation analysis included all 15 registered endpoints, including blood glucose. Blood glucose was excluded from the complete-case PCA because its inclusion reduced the available PCA sample from 135 to 110 fish. The PCA therefore included 14 endpoints and 135 fish." Pairwise n = 110-136 (report per pair). Descriptive only; no causal/latent-construct claims. Source: tables/FigS6_spearman_correlation_matrix_bt1.csv, FigS6_spearman_pvalues_bt1.csv, FigS6_pairwise_n_bt1.csv.

## 9. Canonical PCA specification - FINAL (PC1-PC2 manuscript visualization)
Source: outputs/pca_canonical/.
- BT1; 14 endpoints: time_bright, mtpc, first_choice_binary, latency, num_changes, dist_total, vel_mean, mov_total, stratum_pref, resistance_index, last_flux, attempts, time_in_last_flux, condition_factor (Kc). blood_sugar EXCLUDED.
  (Note: this PCA 14-set includes condition_factor and excludes blood_sugar - the OPPOSITE membership from the 14 modelled ethanol endpoints in Section 7, which include blood_sugar and exclude condition_factor. The two "14" sets are different.)
- Complete-case n = 135 of 136; centered and scaled; no imputation.
- Manuscript biplot displays PC1 vs PC2 ONLY; all 14 loading vectors shown in PC1-PC2 space.
- PC1 = 23.3%; PC2 = 17.2%; cumulative PC1+PC2 = 40.6%.
- PC1 = general activity/performance axis. PC2 = anxiety/exploration-versus-endurance contrast. Signs arbitrary. Exploratory only.
- PC3 (10.3%) is NOT a manuscript axis: no biological interpretation in the main manuscript; it appears only within the complete variance spectrum in the supplementary scree plot/table. The legacy PC1-vs-PC3 plot is NOT an active manuscript figure.

## 10. Equivalence boundary (locked wording)
"Equivalence testing was not conducted because endpoint-specific equivalence margins were not prespecified. Comparisons without detected BH-adjusted differences were therefore not interpreted as evidence that sequential and isolated measurements were interchangeable." No retrospective TOST classifications. (tables/04_battery_tost_equivalence_tests.csv shows all 117 rows "not tested" - do not cite as equivalence outcomes.)

## 11. Fontana framing (locked; verified against references/fontana, 2022.pdf)
Fontana et al. 2022 (Psychopharmacology 239:287-296) compared NTT and LDT test order with 6-min delay-only controls; drug-free fish were comparatively stable (strong NTT-LDT correlation); fluoxetine (100 micrograms/L) and conspecific alarm substance responses varied with test time/order. It used two anxiety assays only (no endurance/physiology) and did not use ethanol. The present study was developed independently and convergently (not a planned extension/replication), spans four domains (LDT, NTT, resistance/endurance, physiology), and - because it lacks Fontana's delay-only/counterbalanced controls - must use "measurement context", never a definitive "order effect" or "carry-over effect". Do not cite Fontana as evidence about ethanol.

## 12. Canonical figure order (files in outputs/manuscript/figures_final/)
1. Fig 1 - Battery architecture and testing contexts (Fig1_battery_design)
2. Fig 2 - Primary battery-context comparisons (Fig2_battery_context)
3. Fig 3 - Endpoint Spearman correlation heatmap, 15 vars (Fig3_correlation_heatmap)
4. Fig 4 - Exploratory PCA, canonical 14-endpoint, PC1-PC2 biplot (Fig4_PCA_biplot)
5. Fig 5 - Ethanol: LDT (Fig5_LDT_anxiety)
6. Fig 6 - Ethanol: NTT (Fig6_NTT)
7. Fig 7 - Ethanol: RN/endurance (Fig7_RN_resistance)
8. Fig 8 - Ethanol: blood glucose (Fig8_blood_glucose)
- Supplementary: S1 PCA scree (full variance spectrum), S2 LDT choice, S3 zone transitions, S4 mean velocity, S5 movement time, S6 attempts, S7 condition factor K (descriptive-only caption).

## 13. Canonical table order (proposed)
- Table 1 - Groups, contexts, timing, cell sizes. Table 2 - Endpoint registry. Table 3 - Battery-context estimates/CIs/adjusted p + comparator (04_battery_adjusted_difference_tests.csv + bootstrap CIs). Table 4 - Ethanol endpoint models (03_ethanol_factorial_results.csv + 03_lastflux_polr_results.csv + hurdle latency). Table 5 - BH-adjusted contrasts / CLD (03_ethanol_cld_letters.csv, 03_ethanol_posthoc_contrasts.csv). Supplementary - full correlation matrix + pairwise n; PCA loadings + full variance spectrum; full cell-wise battery results.

## 14. Terminology rules
- "registered endpoints" / "modelled endpoints" (never "primary endpoints").
- "measurement context" (never "order/carry-over effect").
- "context differences detected" / "no BH-adjusted difference detected" (never "equivalent"/"validated").
- "exploratory" for PCA and correlation.
- "time-dependent reversal" preferred over "biphasic" unless a specific supported hypothesis requires "biphasic".
- Battery labels: BT1 sequential; BT2 alternative LDT/NTT; BT3 isolated endurance.

## 15. Unresolved factual items
1. latency in the canonical 03 table flags latency:exposure BH-significant (p_adj=0.048), but the governing hurdle model is null. Any Table 4 export must annotate latency as hurdle-null.
2. Blood glucose reporting scale: CLD emmeans are aligned-rank values, not mg/dL; Results must pair CLD groupings with raw mg/dL medians from the descriptive table.
3. Battery-context coverage in figures: only 3 detected endpoints are plotted (Fig 2 panels); the remaining detected differences and all effect sizes/CIs are table-only.
4. (RESOLVED Session 2B) Condition-factor formula: K = 100 x body mass(g) / standard length(cm)^3, verified against 06_condition_factor_audit.csv and 01_qc_condition_factor_audit.csv (correlation 1.0; discrepancy approx 2e-15; BT1 n=136; status pass). The thesis wording (x10^6) is a typographical inconsistency; the audited operational definition (x100, standard length ls) is used. Condition factor remains descriptive/control, part of the correlation and PCA, not an ethanol endpoint model.
5. (RESOLVED Session 2B; Figure CORRECTED Session 3) Battery order: BT1 = LDT -> NTT -> resistance; BT2 = NTT -> LDT (reversed, no resistance); BT3 = isolated resistance. Figure 1 was corrected in Session 3 (BT2 now NTT -> LDT); the superseded version is archived under archive_figures_superseded/.
(RESOLVED earlier: condition-factor model provenance - none exists; treated as descriptive/control. Endpoint count - 14 modelled incl. blood_sugar.)

## 16. Superseded claims and values (flag wherever they appear)
- 15-endpoint PCA; PCA n=110; PC1=20.2%; PC2=15.9% -> superseded by 14-endpoint, n=135, PC1=23.3%, PC2=17.2%.
- Old figures_manuscript.R PCA (23.3%/17.3%, different 13-var set) and notebook-05 PCA (22.1%/15.7%, 13-var) -> superseded.
- "top eight loading vectors" / "eight largest" -> all 14 vectors shown.
- Latency ART interaction (p_adj=0.048) -> superseded by hurdle-null.
- "24 of 48 model terms" phrasing -> replaced by endpoint-level count (10 of 14).
- "PC3 = LDT bout-structure axis" and any three-dimensional main-PCA implication -> removed; PC3 retained only in supplementary variance spectrum.
- FigS7 "ART-ANOVA, all terms non-significant" -> unsupported; replaced by descriptive-only.
- Old figure numbering (Figure_01-08; prior Fig1-7) and 10_figure_captions.md (old numbering) -> superseded by Fig1-8/S1-7 in figures_final/.
- Prior Figure 1 (BT2 shown as LDT -> NTT) -> superseded by corrected Figure 1 (BT2 = NTT -> LDT); archived under archive_figures_superseded/ with the SUPERSEDED_wrong_BT2_order suffix.

## 17. AI-use declaration (locked; for later manuscript integration - do NOT insert until the full manuscript is assembled)

**Full declaration (for the manuscript acknowledgements/declaration section):**
"During preparation of this manuscript, the authors used OpenAI GPT-5.6 Sol through Codex (medium reasoning setting) and Anthropic Claude Opus 4.8 through Claude Code (high reasoning setting). These tools assisted with manuscript organization, drafting and language revision, inspection of analysis code, consistency checks among scripts, tables, figures and text, literature organization, and documentation of the analytical workflow. The authors reviewed and verified all AI-assisted outputs against the original data, saved analysis outputs, code and source literature. Final methodological, statistical, interpretive and editorial decisions were made by the human authors, who take full responsibility for the accuracy and integrity of the work."

**Short version (for the Methods/reproducibility section):**
"AI-assisted tools were used for code inspection, workflow documentation and consistency checking among analytical outputs. No statistical result was accepted solely from model-generated text; all reported results were verified against saved analysis outputs."
