# Canonical PCA — single active statement
**Scope:** BT1 full-endpoint exploratory PCA. This file is the **only** active statement of the PCA variable set, complete-case sample, variance explained, loading interpretation, and final figure identity. All other PCA prose is superseded (see `PCA_provenance_and_cleanup_log.md`).
**Generated:** 2026-08-01 · **Generator:** `outputs/manuscript/pca_canonical.py` (documented revision; R unavailable in this environment). Numbers below are computed directly from the canonical output, not transcribed.
**Canonical artifacts:** `outputs/pca_canonical/` (analysis dataset, complete-case record, scaling summary, variance, loadings, scores, provenance). **Figures:** `outputs/manuscript/figures/Fig1_PCA_biplot.(pdf|png)` (panels A+B) and `FigS_PCA_scree.(pdf|png)`.

> **Author decision (2026-08-01): blood glucose is excluded from the PCA.** Requiring complete cases across all 15 endpoints dropped the sample to n = 110 because 25 fish lack blood glucose. To preserve sample size, the PCA uses the **14 non-glucose endpoints** (complete-case **n = 135**; only 1 no-choice fish lost). Blood glucose remains reported through its own endpoint-level model and is retained in the FigS6 Spearman heatmap.

---

## 1. Final variable list and coding (14 endpoints, registered BT1 set)

| # | Endpoint | Short label | Domain | Coding |
|---|----------|-------------|--------|--------|
| 1 | time_bright | Time bright | LDT | audited numeric |
| 2 | mtpc | MTPC | LDT | audited numeric |
| 3 | first_choice_binary | First choice | LDT | 0/1; no-choice/ambiguous = missing |
| 4 | latency | Latency | LDT | audited numeric |
| 5 | num_changes | Zone transitions | LDT | audited count |
| 6 | dist_total | Distance | NTT | audited numeric |
| 7 | vel_mean | Velocity | NTT | audited numeric |
| 8 | mov_total | Movement time | NTT | audited numeric |
| 9 | stratum_pref | Upper stratum | NTT | audited bounded |
| 10 | resistance_index | Resistance index | RN | audited numeric |
| 11 | last_flux | Last flux | RN | ordered step 1–12 (numeric) |
| 12 | attempts | Attempts | RN | audited count |
| 13 | time_in_last_flux | Time in last flux | RN | audited numeric |
| 14 | condition_factor | Condition K | Phys./control | audited Kc (Fulton's K) |

*Excluded from PCA by author decision:* `blood_sugar` (retained in endpoint model + FigS6 heatmap).

Ordinary PCA numerically represents these binary, count, bounded, and ordinal endpoints after standardization; it is therefore used **only for exploratory visualization**, not inference.

## 2. Complete-case sample
- Initial BT1 sample: **136** fish (one row per fish; 138 raw − 2 QC global exclusions).
- Complete-case PCA sample: **135** fish.
- Excluded for missingness: **1** (a single no-choice first-choice observation). No imputation.
- Per-variable non-missing (full BT1): all 14 endpoints = 136 except first_choice = 135. See `outputs/pca_canonical/pca_per_variable_nonmissing.csv`.

## 3. Variance explained (canonical)
| Component | Variance | Cumulative |
|-----------|----------|------------|
| PC1 | **23.3%** | 23.3% |
| PC2 | **17.2%** | 40.6% |
| PC3 | 10.3% | 50.8% |
| PC4 | 9.2% | 60.0% |
| PC5 | 7.4% | 67.4% |

## 4. Loading interpretation (signs arbitrary)
- **PC1 (23.3%) — general activity / performance axis:** Distance (+0.45), Velocity (+0.37), Movement time (+0.36), Resistance index (+0.34), Last flux (+0.33).
- **PC2 (17.2%) — anxiety/exploration vs. endurance contrast:** Time bright (+0.42), Velocity (+0.29), Distance (+0.28) oppose Last flux (−0.36) and Resistance index (−0.33).
- **PC3 (10.3%) — LDT bout-structure axis:** MTPC (+0.51), Last flux (+0.43), Resistance index (+0.42), Time bright (+0.32), opposed by Zone transitions (−0.38).

## 5. Redundancy disclosure (retained by design)
All registered non-glucose endpoints were retained to visualize the complete covariance structure, including strongly correlated and mathematically related measures. Strongest retained redundancies (Spearman ρ, FigS6):
- resistance_index & last_flux: ρ ≈ 0.98 (operationally related — IRN derives from the last-flux step);
- dist_total & vel_mean: ρ ≈ 0.87 (mathematically related — velocity derives from distance/time);
- time_bright & mtpc: ρ ≈ 0.77 (related LDT phototaxis measures).
Because the PCA objective is visualization rather than a parsimonious predictor set, these were **not** removed. Co-directional loadings must **not** be read as independent biological confirmation.

---

## 6. Methods paragraph (canonical)
> A single exploratory principal component analysis (PCA) was conducted using 14 registered BT1 behavioral, endurance, and condition endpoints (LDT: time in bright zone, mean time per crossing, first choice, latency, zone transitions; NTT: total distance, mean velocity, movement time, upper-stratum time; endurance: resistance index, last flux, attempts, time in last flux; condition: condition factor K). Blood glucose was omitted from the PCA to preserve sample size, as it was missing for 25 fish; it is reported separately through its endpoint-level model. Analyses used fish-level BT1 data (one row per fish) with variables resolved through the audited endpoint registry. First choice was coded 0/1 with no-choice/ambiguous observations set to missing; last flux used its documented ordered step coding; condition factor used the audited Kc value; remaining endpoints used audited numeric values. All variables were centered and scaled to unit variance, and the PCA was computed on complete cases across the 14-endpoint set (n = 135 of 136; one no-choice fish excluded; no imputation). Because ordinary PCA numerically represents binary, count, bounded, and ordinal endpoints after standardization, the analysis was treated strictly as an exploratory visualization of multivariate endpoint covariance and was not used to test ethanol effects; ethanol-effect inference rests solely on the endpoint-level models. Component signs are arbitrary, and no inferential tests were run on component scores.

## 7. Results paragraph (canonical)
> The exploratory PCA of the 14 standardized BT1 endpoints (n = 135) summarized multivariate covariance across the battery. The first two components explained 23.3% and 17.2% of total variance respectively (cumulative 40.6%; PC3 10.3%). PC1 loaded most strongly on activity and performance endpoints (total distance, mean velocity, movement time) together with the endurance measures (resistance index, last flux), describing a general activity/performance axis. PC2 contrasted anxiety/exploration and locomotor measures (time in bright zone, velocity, distance) with the endurance measures (last flux, resistance index). Because several retained endpoints are strongly correlated or mathematically related (e.g., resistance index and last flux, ρ ≈ 0.98; distance and velocity, ρ ≈ 0.87), co-directional loadings are not independent confirmation of a single biological effect. Score-space organization by treatment and exposure is shown descriptively only (Figure 1); no treatment separation is claimed from the PCA, as ethanol effects are established exclusively by the endpoint-level models.

## 8. Figure 1 caption (canonical)
> **Figure 1. Exploratory PCA of the complete BT1 endpoint set.** Principal component analysis of 14 registered, standardized BT1 endpoints (behavioral, endurance, and condition measures) in complete-case fish (n = 135 of 136). Blood glucose was excluded from the PCA to preserve sample size and is reported via its endpoint-level model. **(A)** Score–loading biplot of PC1 (23.3%) versus PC2 (17.2%); points are individual fish coloured by ethanol treatment (CTR, 0.5%, 1%) and shaped by exposure duration (1 h, 24 h, 96 h) for orientation only; all 14 endpoint loading vectors are shown. **(B)** Enlarged loading vectors for all 14 endpoints from the same PCA object, coloured by assay domain. The PCA is exploratory and descriptive: it visualizes multivariate covariance among endpoints and is not a test of ethanol effects. Component signs are arbitrary. Strongly correlated endpoints (e.g., resistance index and last flux) were deliberately retained to represent the full endpoint structure and should not be interpreted as independent effects.

## 9. Confirmation
No endpoint-level models, battery-context comparisons, hurdle/Firth/ART/polr models, effect sizes, or any non-PCA statistical decision were changed. Only the PCA specification and its direct derivatives were revised, per the author decision.
