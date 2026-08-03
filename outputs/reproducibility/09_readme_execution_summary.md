# Reproducibility and execution summary

Generated on: 2026-06-27

## Project execution order

1. `python/00_data_wrangling.ipynb`
2. `notebooks/00_project_setup.Rmd`
3. `notebooks/01_data_audit_and_qc.Rmd`
4. `notebooks/02_endpoint_hierarchy_and_assumptions.Rmd`
5. `notebooks/03_ethanol_factorial_models.Rmd`
6. `notebooks/04_battery_effect_analysis.Rmd`
7. `notebooks/05_multivariate_pca_structure.Rmd`
8. `notebooks/06_sensitivity_and_robustness.Rmd`
9. `notebooks/07_reporting_tables_and_figures.Rmd`
10. `notebooks/08_statistical_methods_text.Rmd`
11. `notebooks/09_reproducibility_audit.Rmd`

## Locked analysis rules

- Endpoint roles are controlled by the endpoint registry, not by a primary/secondary endpoint hierarchy.
- Endpoint-level ethanol effects are tested with treatment, exposure, and treatment-by-exposure models.
- Battery-context comparisons are separate from endpoint-level ethanol models.
- One single BT1 full-battery PCA is used for multivariate visualization.
- PCA variables are centered and scaled before PCA.
- PCA component labels are assigned from loadings.
- PCA does not replace endpoint-level ethanol models.
- Condition factor is reported as condition factor (K) only when the audit supports formula and value consistency.

## Audit status

- Missing required notebook files: 11
- Missing required outputs: 1
- Missing reporting files: 0
- Methods wording flags/reviews: 2

## Reproducibility outputs

- `outputs/reproducibility/09_file_inventory.csv`
- `outputs/reproducibility/09_notebook_inventory.csv`
- `outputs/reproducibility/09_expected_output_audit.csv`
- `outputs/reproducibility/09_package_versions.csv`
- `outputs/reproducibility/09_session_info.txt`
- `outputs/reproducibility/09_reporting_bundle_audit.csv`
- `outputs/reproducibility/09_methods_text_audit.csv`
- `outputs/reproducibility/09_claim_source_map.csv`

## Next step

If required outputs are missing, rerender or patch the corresponding upstream notebook before manuscript writing. If no required outputs are missing, proceed to Notebook 10.
