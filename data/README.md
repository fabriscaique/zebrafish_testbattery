# Data

## `raw/masters_data.csv`
The single canonical raw dataset: 414 records, one per fish, from the original
thesis experiment (CEUA/UEL 040.2020). Column `battery_suite` identifies the
testing context (1 = BT1 sequential, 2 = BT2 reversed behavioural, 3 = BT3
isolated endurance). No new animals were used in the reanalysis.

## `processed/`
Generated from `raw/masters_data.csv` by `code/notebooks/00_data_wrangling.ipynb`.

| File | Contents |
|---|---|
| `battery_suite_1/2/3.csv` | Wrangled per-context files with parse metadata and QC flags |
| `bt1_audited.csv`, `bt2_audited.csv`, `bt3_audited.csv` | Audited analysis-ready datasets after QC |

Analysed samples: 410 fish (414 raw − 4 global exclusions).
BT1 n = 136, BT2 n = 139, BT3 n = 135. Per-cell n = 12–16.

## Missing data
No values were imputed anywhere in the pipeline. Endpoint-specific missingness:
one no-choice first-choice record in BT1 and one in BT2; blood glucose
unavailable for 25 BT1, 102 BT2, and 62 BT3 fish.

## Provenance
Exclusions are itemised in `outputs/logs/exclusion_log.csv`; QC records are the
`outputs/logs/01_qc_*` family. Full history is in
`documentation/PROJECT_PROVENANCE_AI_AND_DEVELOPMENT_HISTORY.md`.
