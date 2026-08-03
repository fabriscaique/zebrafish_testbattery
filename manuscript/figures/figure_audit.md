# Figure package audit

**Task:** match every figure referenced by the final manuscript to its canonical image and package it for submission. Packaging and provenance only — no figure was regenerated, edited, resized, relabelled, recompressed, or otherwise modified.

**Canonical source (sole):** `outputs/manuscript/figures_final/`
**Destination:** `final_manuscript/figures/`
**Result:** 15 figures × 2 formats = **30 files**, all byte-identical to source (SHA-256 verified in `figure_manifest.csv`).

---

## 1. BLOCKING ISSUE — `4_discussion.pdf` is not the Discussion

`final_manuscript/manuscript/4_discussion.pdf` is a **byte-identical duplicate of `3_results.pdf`**.

| File | SHA-256 | Pages | Words | Opens with |
|---|---|---|---|---|
| `3_results.pdf` | `c05aed0e9c357785348907c7c943f7f7ce907a6f98004abc5264685ce6506032` | 6 | 2,474 | "3 Results 3.1" |
| `4_discussion.pdf` | `c05aed0e9c357785348907c7c943f7f7ce907a6f98004abc5264685ce6506032` | 6 | 2,474 | "3 Results 3.1" |

Both end on the condition-factor sentence from Results §3.4.5. The Discussion text is absent from `final_manuscript/manuscript/`. **The Discussion PDF needs to be regenerated and placed in that folder.** The harmonised Discussion source is available at `outputs/manuscript/31_discussion_harmonised_overleaf.tex`.

**Impact on this task: none.** The figure audit is unaffected, because the Results PDF alone cites all 15 figures, and the harmonised Discussion source in the repository was checked and cites no figures directly (its prose is narrative). The complete reference set is therefore fully determined.

---

## 2. Figure references found in the manuscript PDFs

| Section | Figures referenced |
|---|---|
| `1_intro.pdf` | none |
| `2_methods.pdf` | Figure 1 |
| `3_results.pdf` | Figures 1, 2 (A, B, C), 3, 4, 5 (A, B), 6 (A, B), 7, 8; Figures S1, S2 (A, B), S3, S4, S5, S6, S7 |
| `4_discussion.pdf` | (duplicate of Results — see §1) |

Union of references = **Figures 1–8 and S1–S7**, exactly matching the 15 captions in `outputs/manuscript/20_final_figure_captions.md`. Every reference has a matching file; no reference was unmatched; no canonical file was left unused.

---

## 3. Renumbering confirmed (not copied blindly)

Verified against `00_figure_renumbering_map.csv`:

| Historical name | Canonical | Status |
|---|---|---|
| `Fig1_PCA_biplot` | **Figure 4** | confirmed |
| `Fig6_battery_comparison` | **Figure 2** | confirmed |
| `FigS6_correlation_heatmap` | **Figure 3** | confirmed |
| `Fig2_LDT_anxiety` | Figure 5 | confirmed |
| `Fig4_NTT` | Figure 6 | confirmed |
| `Fig5_RN_resistance` | Figure 7 | confirmed |
| `Fig7_blood_glucose` | Figure 8 | confirmed |
| `FigS_PCA_scree` | Figure S1 | confirmed |
| `Fig3_LDT_choice` | Figure S2 | confirmed |
| `FigS1_num_changes` | Figure S3 | confirmed |
| `FigS2_vel_mean` | Figure S4 | confirmed |
| `FigS3_mov_total` | Figure S5 | confirmed |
| `FigS4_attempts` | Figure S6 | confirmed |
| `FigS5_condition_K` | Figure S7 | confirmed |

No obsolete numbering was used in file selection or naming.

---

## 4. Content verification

Panel content read from each figure and checked against the locked captions:

| Canonical | Verified content | Check |
|---|---|---|
| Figure 2 | Time in bright zone; total distance; swimming-resistance index (IRN) | boxplots with individual points, **no** effect-size/forest markers — distributions only, as required |
| Figure 3 | 15 endpoints incl. blood glucose and condition factor; pairwise n = 110–136 | 15-variable version confirmed |
| Figure 4 | 14 endpoints, complete cases n = 135, **PC1 = 23.3%**, **PC2 = 17.2%**, all 14 loading vectors | canonical PCA confirmed |
| Figure 5 | A time in bright zone; B mean time per crossing | correct |
| Figure 6 | A total distance; B time in upper stratum | correct |
| Figure 7 | Swimming-resistance index only — **not** final flow step | correct |
| Figure 8 | Blood glucose (mg/dL) | correct |
| Figure S1 | Scree, 14 components, cumulative variance | correct component count |
| Figure S2 | A first choice (%); B latency to first entry | correct |
| Figure S4 | Mean velocity (cm/s) | correct |
| Figure S5 | Total movement time | correct |
| Figure S6 | Number of attempts | correct |
| Figure S7 | Condition factor K | correct |
| `last_flux` | **No figure exists** | correct — remains a table-only result; no figure was invented |

No figure contains advisor notes or drafting instructions.

---

## 5. ISSUES FOUND — obsolete text baked into eight images

The following figures carry **stale internal titles** rendered into the image itself. The brief forbids regenerating, editing, or relabelling figures, so these were packaged **as-is** and are flagged here for the author to decide on.

| Canonical | Internal title in the image | Problem |
|---|---|---|
| **Figure 3** | "Figure S6. BT1 endpoint correlation structure" | Obsolete number — was supplementary, now main Figure 3 |
| **Figure 4** | "Figure 1. Exploratory PCA of 14 standardized BT1 endpoints…" | Obsolete number — was Figure 1, now Figure 4 |
| **Figure S1** | "PCA scree (canonical **15-endpoint** BT1 PCA)" | **Factual error.** The plot correctly shows 14 components and the canonical PCA uses 14 endpoints; the title text is stale from before blood glucose was excluded |
| **Figure S3** | "S1. LDT: Zone transitions" | Obsolete number — now S3 |
| **Figure S4** | "S2. NTT: Mean velocity" | Obsolete number — now S4 |
| **Figure S5** | "S3. NTT: Movement time" | Obsolete number — now S5 |
| **Figure S6** | "S4. RN: Number of attempts" | Obsolete number — now S6 |
| **Figure S7** | "S5. Condition factor K" | Obsolete number — now S7 |

A ninth, separate labelling issue:

| Canonical | Internal label | Problem |
|---|---|---|
| **Figure 2** | Legend reads "Sequential (BT1)", "**Isolated (BT2)**", "Isolated (BT3)" | BT2 is the **reversed behavioural context**, not an isolated one. Only BT3 is isolated. This contradicts the locked Methods terminology (§2.5.2) and the same wording was already corrected in the Figure 2 caption in an earlier session |

**Recommendation.** Figures 1, 5, 6, 7, 8 and S2 are clean (no internal figure number). The eight above would need their titles regenerated from source to be submission-ready, and Figure 2 needs its legend corrected from "Isolated (BT2)" to "Reversed (BT2)" or equivalent. Many journals strip or ignore in-figure titles, so this may be acceptable as-is for some targets — but the Figure S1 "15-endpoint" text and the Figure 2 "Isolated (BT2)" legend are factual/terminological errors rather than cosmetic ones, and should be corrected before submission.

---

## 6. Provenance and integrity

- Every copied file originates from `outputs/manuscript/figures_final/`. No file was taken from `outputs/manuscript/figures/`, `outputs/figures/`, legacy reporting directories, or draft PCA directories.
- All 30 source/destination SHA-256 pairs match (`figure_manifest.csv`, `verification_status = VERIFIED`).
- `00_figure_renumbering_map.csv` was used as provenance only and was **not** copied into the figure folder.
- `final_manuscript/figures/` did not previously exist, so no pre-existing file was compared, replaced, or deleted. No unexpected or extra files were found.
- The four manuscript PDFs, existing figures, source scripts, data, models, tables, and manuscript prose were not modified.

## 7. Interactive PCA

Canonical deployable package: **`docs/pca3d/`**. It is a website, not a static figure, and was deliberately not copied into this folder; its location is recorded in `interactive_pca_location.txt`. The obsolete standalone file `outputs/figures/05_pca_interactive_3d_bt1.html` was **not** used. The Methods reference the interactive display in §2.9.6 and §2.10.

## 8. Folder contents

30 figure files (15 PDF + 15 PNG), plus `figure_manifest.csv`, `figure_captions.md`, `figure_audit.md`, and `interactive_pca_location.txt`.
