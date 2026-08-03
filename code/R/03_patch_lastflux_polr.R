# =============================================================================
# 03_patch_lastflux_polr.R
# Standalone patch — proportional odds model for last_flux (Task 20)
#
# Context:
#   The main pipeline (03_ethanol_factorial_models.Rmd) dispatched last_flux
#   through the count model branch because its data_type is "ordinal/step" and
#   that branch handled both "count" and "ordinal/step". Inside that branch,
#   variance/mean = 1.039 < 1.5 threshold → Poisson was auto-selected.
#   Poisson is conceptually wrong for last_flux: flux levels are non-equidistant
#   ordered effort categories, not event counts.
#   Correct model: proportional odds logistic regression (MASS::polr).
#
# This script:
#   1. Reads bt1_audited.csv and applies the same factor standardisation as 03
#   2. Fits MASS::polr(last_flux_ord ~ treatment * exposure, Hess = TRUE)
#   3. Tests terms via car::Anova() (likelihood ratio, type II)
#   4. Applies BH correction within this model family
#   5. Writes outputs/tables/03_lastflux_polr_results.csv
#   6. Saves outputs/models/03_model_ethanol_last_flux_polr.rds
#   7. Backs up current factorial results to outputs/logs/ before any edit
#   8. Replaces last_flux rows in outputs/tables/03_ethanol_factorial_results.csv
#
# Run order: run this before 03_patch_posthoc_contrasts.R and before
#            rerunning 07_reporting_tables_and_figures.Rmd.
#
# Packages required: MASS, car
# =============================================================================

# -- 0. Guard: required packages ----------------------------------------------
for (pkg in c("MASS", "car")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Required package not found: ", pkg,
         ". Install it with install.packages('", pkg, "')")
  }
}

# -- 1. Project root ----------------------------------------------------------
find_root <- function(start = getwd()) {
  path <- normalizePath(start, winslash = "/", mustWork = FALSE)
  for (i in seq_len(10)) {
    markers <- c(
      list.files(path, pattern = "\\.Rproj$", full.names = FALSE),
      if (dir.exists(file.path(path, ".git")))          ".git",
      if (dir.exists(file.path(path, "data_raw")))      "data_raw",
      if (dir.exists(file.path(path, "data_processed"))) "data_processed"
    )
    if (length(markers) > 0) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) break
    path <- parent
  }
  normalizePath(start, winslash = "/", mustWork = FALSE)
}

ROOT <- find_root()
cat("Project root:", ROOT, "\n")

# -- 2. Paths -----------------------------------------------------------------
f_bt1        <- file.path(ROOT, "data_processed", "bt1_audited.csv")
f_results    <- file.path(ROOT, "outputs", "tables", "03_ethanol_factorial_results.csv")
f_backup     <- file.path(ROOT, "outputs", "logs",
                           "03_ethanol_factorial_results_pre_lastflux_patch.csv")
f_polr_out   <- file.path(ROOT, "outputs", "tables", "03_lastflux_polr_results.csv")
f_model_out  <- file.path(ROOT, "outputs", "models",
                           "03_model_ethanol_last_flux_polr.rds")

stopifnot("bt1_audited.csv not found"              = file.exists(f_bt1))
stopifnot("03_ethanol_factorial_results.csv not found" = file.exists(f_results))

# -- 3. Helpers (mirrors 03_ethanol_factorial_models.Rmd) ---------------------
standardize_exposure <- function(x) {
  y <- trimws(as.character(x))
  y <- ifelse(y %in% c("1",  "1h",  "1H"),  "1h",
       ifelse(y %in% c("24", "24h", "24H"), "24h",
       ifelse(y %in% c("96", "96h", "96H"), "96h", y)))
  factor(y, levels = c("1h", "24h", "96h"))
}

standardize_factors <- function(df) {
  if ("treatment" %in% names(df))
    df$treatment <- factor(as.character(df$treatment), levels = c("0", "0.5", "1"))
  if ("exposure" %in% names(df))
    df$exposure  <- standardize_exposure(df$exposure)
  df
}

as_bool <- function(x) {
  if (is.logical(x)) return(x)
  if (is.numeric(x)) return(x == 1)
  tolower(as.character(x)) %in% c("true", "1", "yes", "y")
}

# -- 4. Load and prepare data -------------------------------------------------
cat("\nLoading bt1_audited.csv ...\n")
bt1 <- read.csv(f_bt1, stringsAsFactors = FALSE)
bt1 <- standardize_factors(bt1)

d <- bt1[!is.na(bt1$last_flux) &
          !is.na(bt1$treatment) &
          !is.na(bt1$exposure), ]

if ("global_exclusion_flag" %in% names(d)) {
  d <- d[!as_bool(d$global_exclusion_flag), ]
}

d$treatment <- droplevels(d$treatment)
d$exposure  <- droplevels(d$exposure)

# Ordered factor for polr — levels are the observed integer scale 1–12
flux_levels  <- sort(unique(d$last_flux))
d$last_flux_ord <- factor(d$last_flux, levels = flux_levels, ordered = TRUE)

cat("n for model:", nrow(d), "\n")
cat("last_flux levels:", paste(flux_levels, collapse = ", "), "\n")
cat("treatment levels:", paste(levels(d$treatment), collapse = ", "), "\n")
cat("exposure levels: ", paste(levels(d$exposure),  collapse = ", "), "\n")

# -- 5. Fit proportional odds model -------------------------------------------
cat("\nFitting MASS::polr(last_flux_ord ~ treatment * exposure) ...\n")
fit_polr <- MASS::polr(last_flux_ord ~ treatment * exposure,
                       data  = d,
                       Hess  = TRUE,
                       method = "logistic")   # cumulative logit = proportional odds
cat("Model converged.\n\n")
print(summary(fit_polr))

# -- 6. Likelihood-ratio ANOVA table (type II via car) -----------------------
cat("\nRunning car::Anova(type = 2) ...\n")
anova_tbl <- car::Anova(fit_polr, type = 2)
print(anova_tbl)

# Tidy into a data frame matching 03_ethanol_factorial_results.csv columns
terms    <- rownames(anova_tbl)
p_raw    <- as.numeric(anova_tbl[, grep("Pr", names(anova_tbl), value = TRUE)[1]])
chisq    <- as.numeric(anova_tbl[, grep("Chisq|LR", names(anova_tbl), value = TRUE)[1]])
df_vals  <- as.numeric(anova_tbl[["Df"]])

# BH correction within this model
p_adj <- p.adjust(p_raw, method = "BH")

# Pull metadata from the existing last_flux rows rather than hardcoding
existing <- read.csv(f_results, stringsAsFactors = FALSE)
lf_meta  <- existing[existing$endpoint == "last_flux", ][1, ]

result_df <- data.frame(
  endpoint              = "last_flux",
  resolved_variable     = as.character(lf_meta$resolved_variable),
  domain                = as.character(lf_meta$domain),
  source_test           = as.character(lf_meta$source_test),
  data_type             = "ordinal/step",
  model_family          = "ordinal_or_rank_based_model",
  dataset               = "BT1",
  model_method          = "proportional odds logistic regression (polr)",
  term                  = terms,
  df                    = df_vals,
  statistic             = chisq,
  p_value               = p_raw,
  p_adj_bh              = p_adj,
  effect_flag_bh_0_05   = !is.na(p_adj) & p_adj < 0.05,
  model_note            = paste0(
    "Proportional odds logistic regression (MASS::polr, cumulative logit). ",
    "Ordered factor outcome: levels 1-", max(flux_levels), " (n=", nrow(d), "). ",
    "LR chi-sq via car::Anova type II. BH correction within model. ",
    "Replaces misspecified Poisson GLM (variance/mean=1.039). ",
    "Run: 03_patch_lastflux_polr.R, ", Sys.Date()
  ),
  stringsAsFactors = FALSE
)

cat("\nPolr results with BH correction:\n")
print(result_df[, c("term", "statistic", "df", "p_value", "p_adj_bh", "effect_flag_bh_0_05")])

# -- 7. Write polr results file -----------------------------------------------
write.csv(result_df, f_polr_out, row.names = FALSE)
cat("\nWrote:", f_polr_out, "\n")

# -- 8. Save model object -----------------------------------------------------
saveRDS(
  list(model             = fit_polr,
       analysis_data     = d,
       endpoint          = "last_flux",
       resolved_variable = "last_flux",
       method            = "proportional odds logistic regression (polr)",
       flux_levels       = flux_levels,
       n_model           = nrow(d),
       patch_date        = as.character(Sys.Date())),
  f_model_out
)
cat("Saved model:", f_model_out, "\n")

# -- 9. Backup original factorial results ------------------------------------
file.copy(f_results, f_backup, overwrite = TRUE)
cat("Backup written:", f_backup, "\n")

# -- 10. Replace last_flux rows in main factorial results --------------------
cat("\nUpdating 03_ethanol_factorial_results.csv ...\n")
factorial <- read.csv(f_results, stringsAsFactors = FALSE)
cat("  Rows before patch:", nrow(factorial), "\n")
cat("  Old last_flux model_method:",
    unique(factorial$model_method[factorial$endpoint == "last_flux"]), "\n")

# Drop old last_flux rows
factorial <- factorial[factorial$endpoint != "last_flux", ]

# Align columns: add any columns present in one df but not the other
for (col in setdiff(names(factorial), names(result_df)))
  result_df[[col]] <- NA
for (col in setdiff(names(result_df), names(factorial)))
  factorial[[col]] <- NA

result_df <- result_df[, names(factorial), drop = FALSE]

# Append corrected rows
factorial <- rbind(factorial, result_df)
cat("  Rows after patch:", nrow(factorial), "\n")
cat("  New last_flux model_method:",
    unique(factorial$model_method[factorial$endpoint == "last_flux"]), "\n")

write.csv(factorial, f_results, row.names = FALSE)
cat("Updated:", f_results, "\n")

# -- 11. Summary --------------------------------------------------------------
cat("\n=== 03_patch_lastflux_polr.R COMPLETE ===\n")
cat("Outputs written:\n")
cat("  Polr results CSV : ", f_polr_out,  "\n")
cat("  Model object RDS : ", f_model_out, "\n")
cat("  Backup of original:", f_backup,    "\n")
cat("  Updated factorial : ", f_results,  "\n")
cat("\nNext step: run 03_patch_posthoc_contrasts.R, then rerun 07 and figures.\n")
