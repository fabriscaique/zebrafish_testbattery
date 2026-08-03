# =============================================================================
# 03_patch_posthoc_contrasts.R
# Standalone patch — post-hoc contrasts for BH-significant ART-ANOVA endpoints
# (Task 21)
#
# Context:
#   The main pipeline's fit_continuous_endpoint() generates ART-ANOVA results
#   but never produces post-hoc contrasts: the ART-ANOVA branch always returns
#   posthoc = data.frame(). Post-hoc logic existed only in the LM fallback
#   branch, which was never reached. Result: 03_ethanol_posthoc_contrasts.csv
#   is empty and no manuscript figure can carry compact letter display.
#
# ARTool alignment rule (why component selection matters):
#   ARTool creates a separate aligned-and-ranked response for each model term.
#   Post-hoc contrasts must use the artlm component that matches the significant
#   term being interpreted. Using the treatment-aligned response for an
#   interaction-driven endpoint produces letters that do not correspond to the
#   significant term.
#
#   Component priority for treatment comparisons (used for CLD / figure letters):
#     treatment:exposure BH-sig  → artlm(..., "treatment:exposure")
#     treatment BH-sig           → artlm(..., "treatment")
#     exposure BH-sig only       → artlm(..., "exposure")   [fallback]
#
#   Component for exposure comparisons (contrast table only):
#     treatment:exposure BH-sig  → artlm(..., "treatment:exposure")
#     exposure BH-sig            → artlm(..., "exposure")
#     neither                    → artlm(..., "treatment")  [fallback]
#
# This script writes:
#   outputs/tables/03_ethanol_posthoc_contrasts.csv  — full pairwise contrast table
#   outputs/tables/03_ethanol_cld_letters.csv        — CLD letter assignments
#                                                      for figure annotation
#
# Run order: 03_patch_lastflux_polr.R first, then this script.
# Packages required: ARTool, emmeans, multcomp
# =============================================================================

# -- 0. Guard: required packages ----------------------------------------------
for (pkg in c("ARTool", "emmeans", "multcomp")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Required package not found: ", pkg,
         ". Install it with install.packages('", pkg, "')")
  }
}
# multcompView: used for CLD letter groupings (replaces multcomp::cld which was
# removed in newer emmeans versions).
if (!requireNamespace("multcompView", quietly = TRUE)) {
  message("Installing multcompView for CLD letter groupings...")
  install.packages("multcompView", repos = "https://cran.rstudio.com/")
}

# -- 1. Project root ----------------------------------------------------------
find_root <- function(start = getwd()) {
  path <- normalizePath(start, winslash = "/", mustWork = FALSE)
  for (i in seq_len(10)) {
    markers <- c(
      list.files(path, pattern = "\\.Rproj$", full.names = FALSE),
      if (dir.exists(file.path(path, ".git")))            ".git",
      if (dir.exists(file.path(path, "data_raw")))        "data_raw",
      if (dir.exists(file.path(path, "data_processed")))  "data_processed"
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
f_results    <- file.path(ROOT, "outputs", "tables", "03_ethanol_factorial_results.csv")
f_models_dir <- file.path(ROOT, "outputs", "models")
f_contrasts  <- file.path(ROOT, "outputs", "tables", "03_ethanol_posthoc_contrasts.csv")
f_cld        <- file.path(ROOT, "outputs", "tables", "03_ethanol_cld_letters.csv")

stopifnot("03_ethanol_factorial_results.csv not found" = file.exists(f_results))
stopifnot("outputs/models/ directory not found"        = dir.exists(f_models_dir))

# -- 3. Identify target endpoints ---------------------------------------------
# ART-ANOVA endpoints with at least one BH-significant term, excluding latency.
# Latency is excluded because its ART interaction (p_adj = 0.048) is a
# zero-inflation artefact — it is superseded by the hurdle model (all null).

factorial <- read.csv(f_results, stringsAsFactors = FALSE)

art_sig <- factorial[
  !is.na(factorial$effect_flag_bh_0_05) &
  as.logical(factorial$effect_flag_bh_0_05) &
  !is.na(factorial$model_method) &
  factorial$model_method == "ART-ANOVA" &
  factorial$endpoint != "latency",
]

target_endpoints <- unique(art_sig$endpoint)

cat("\nBH-significant ART-ANOVA endpoints (latency excluded):\n")
cat(paste(" ", target_endpoints, collapse = "\n"), "\n\n")

if (length(target_endpoints) == 0) {
  stop("No BH-significant ART-ANOVA endpoints found. ",
       "Check that 03_patch_lastflux_polr.R has been run and that ",
       "03_ethanol_factorial_results.csv contains ART-ANOVA results.")
}

# -- 4. ART component selectors -----------------------------------------------
# Returns which artlm component to use for treatment comparisons (CLD + figures)
trt_component <- function(factorial_df, ep_name) {
  sig <- factorial_df$term[
    factorial_df$endpoint == ep_name &
    !is.na(factorial_df$effect_flag_bh_0_05) &
    as.logical(factorial_df$effect_flag_bh_0_05)
  ]
  if (any(grepl("treatment:exposure", sig, fixed = TRUE))) return("treatment:exposure")
  if (any(sig == "treatment"))                              return("treatment")
  return("exposure")   # exposure-only endpoint: compare exposures instead
}

# Returns which artlm component to use for exposure comparisons (contrast table)
exp_component <- function(factorial_df, ep_name) {
  sig <- factorial_df$term[
    factorial_df$endpoint == ep_name &
    !is.na(factorial_df$effect_flag_bh_0_05) &
    as.logical(factorial_df$effect_flag_bh_0_05)
  ]
  if (any(grepl("treatment:exposure", sig, fixed = TRUE))) return("treatment:exposure")
  if (any(sig == "exposure"))                              return("exposure")
  return("treatment")  # treatment-only endpoint: exposure contrasts are not primary
}

# -- 5. Contrast and CLD functions --------------------------------------------

# Pairwise contrasts for one endpoint: two families with BH correction each.
run_contrasts <- function(fit_art, ep_name, comp_trt, comp_exp, meta_row) {
  tryCatch({
    # Treatment comparisons within each exposure level
    em_trt <- emmeans::emmeans(
      ARTool::artlm(fit_art, comp_trt),
      ~ treatment | exposure
    )
    ct_trt <- as.data.frame(
      emmeans::contrast(em_trt, method = "pairwise", adjust = "BH")
    )
    ct_trt$contrast_family <- "treatment_within_exposure"
    ct_trt$art_component   <- comp_trt

    # Exposure comparisons within each treatment level
    em_exp <- emmeans::emmeans(
      ARTool::artlm(fit_art, comp_exp),
      ~ exposure | treatment
    )
    ct_exp <- as.data.frame(
      emmeans::contrast(em_exp, method = "pairwise", adjust = "BH")
    )
    ct_exp$contrast_family <- "exposure_within_treatment"
    ct_exp$art_component   <- comp_exp

    out <- rbind(ct_trt, ct_exp)
    out$endpoint    <- ep_name
    out$domain      <- as.character(meta_row$domain[1])
    out$source_test <- as.character(meta_row$source_test[1])
    out$dataset     <- "BT1"
    out$patch_date  <- as.character(Sys.Date())
    out
  }, error = function(e) {
    warning("Contrasts failed for ", ep_name, ": ", conditionMessage(e))
    data.frame()
  })
}

# CLD compact letter display for treatment | exposure.
# Uses pairwise BH-adjusted p-values + multcompView::multcompLetters().
# Pair names are built by splitting emmeans contrast strings on " - " (fixed),
# then stripping the factor name prefix — avoids regex ambiguity that caused
# silent multcompLetters failures in the previous version.
run_cld <- function(fit_art, ep_name, comp_trt, meta_row) {
  tryCatch({
    m_aligned <- ARTool::artlm(fit_art, comp_trt)
    em_trt    <- emmeans::emmeans(m_aligned, ~ treatment | exposure)
    em_sum    <- as.data.frame(em_trt)

    # Pairwise contrasts with BH adjustment
    pw <- as.data.frame(
      emmeans::contrast(em_trt, method = "pairwise", adjust = "BH")
    )

    # Parse "treatment0 - treatment0.5" → "0:0.5"
    # strsplit on fixed " - " is unambiguous regardless of factor name or level values
    pw$pair <- sapply(as.character(pw$contrast), function(con) {
      sides <- strsplit(con, " - ", fixed = TRUE)[[1]]
      sides <- trimws(gsub("treatment", "", sides, fixed = TRUE))
      paste(sides, collapse = "-")
    })

    # Build letter groups per exposure level
    exposures <- unique(em_sum$exposure)
    cld_list  <- lapply(exposures, function(exp_level) {
      pw_sub <- pw[pw$exposure == exp_level, , drop = FALSE]
      em_sub <- em_sum[em_sum$exposure == exp_level, , drop = FALSE]

      p_vec  <- setNames(pw_sub$p.value, pw_sub$pair)
      trt_lv <- as.character(em_sub$treatment)

      # No fallback: if multcompLetters fails, let the outer tryCatch surface it
      lt <- multcompView::multcompLetters(p_vec, threshold = 0.05)$Letters

      em_sub$.group <- trimws(lt[trt_lv])
      em_sub$.group[is.na(em_sub$.group)] <- "?"
      em_sub
    })

    cld_out               <- do.call(rbind, cld_list)
    rownames(cld_out)     <- NULL
    cld_out$art_component <- comp_trt
    cld_out$endpoint      <- ep_name
    cld_out$domain        <- as.character(meta_row$domain[1])
    cld_out$source_test   <- as.character(meta_row$source_test[1])
    cld_out$dataset       <- "BT1"
    cld_out$patch_date    <- as.character(Sys.Date())
    cld_out
  }, error = function(e) {
    warning("CLD failed for ", ep_name, ": ", conditionMessage(e))
    data.frame()
  })
}

# -- 6. Loop over target endpoints --------------------------------------------
all_contrasts <- list()
all_cld       <- list()

for (ep in target_endpoints) {
  cat("Processing:", ep, "...\n")

  rds_path <- file.path(f_models_dir,
                        paste0("03_model_ethanol_", ep, "_art.rds"))

  if (!file.exists(rds_path)) {
    warning("Model file not found, skipping: ", rds_path)
    next
  }

  obj     <- readRDS(rds_path)
  fit_art <- obj$model

  if (!inherits(fit_art, "art")) {
    warning("Object in ", basename(rds_path), " is not an art model, skipping.")
    next
  }

  meta_row <- factorial[factorial$endpoint == ep, ]
  c_trt    <- trt_component(factorial, ep)
  c_exp    <- exp_component(factorial, ep)

  cat("  Treatment component:", c_trt, "| Exposure component:", c_exp, "\n")

  # Pairwise contrasts
  ct <- run_contrasts(fit_art, ep, c_trt, c_exp, meta_row)
  if (nrow(ct) > 0) {
    all_contrasts[[ep]] <- ct
    cat("  Contrasts:", nrow(ct), "rows\n")
  } else {
    cat("  Contrasts: FAILED\n")
  }

  # CLD letters
  cl <- run_cld(fit_art, ep, c_trt, meta_row)
  if (nrow(cl) > 0) {
    all_cld[[ep]] <- cl
    cat("  CLD:\n")
    print(cl[, c("treatment", "exposure", ".group", "art_component")])
  } else {
    cat("  CLD: FAILED\n")
  }

  cat("\n")
}

# -- 7. Write contrast table --------------------------------------------------
if (length(all_contrasts) == 0) {
  stop("No contrasts were generated. Check that ARTool and emmeans are ",
       "installed and that model .rds files exist in outputs/models/.")
}

contrast_table <- do.call(rbind, all_contrasts)
rownames(contrast_table) <- NULL
write.csv(contrast_table, f_contrasts, row.names = FALSE)
cat("Wrote contrast table:", f_contrasts, "\n")
cat("  Rows:", nrow(contrast_table),
    "| Endpoints:", length(unique(contrast_table$endpoint)), "\n\n")

# -- 8. Write CLD letter table ------------------------------------------------
if (length(all_cld) == 0) {
  warning("No CLD tables were generated.")
} else {
  cld_table <- do.call(rbind, all_cld)
  rownames(cld_table) <- NULL

  # Column order: identification first, then emmeans estimates, then letter
  id_cols     <- c("endpoint", "domain", "source_test", "dataset",
                   "treatment", "exposure", "art_component")
  stat_cols   <- c("emmean", "SE", "df", "lower.CL", "upper.CL")
  letter_cols <- c(".group", "patch_date")
  keep_cols   <- intersect(c(id_cols, stat_cols, letter_cols), names(cld_table))
  cld_table   <- cld_table[, keep_cols, drop = FALSE]

  write.csv(cld_table, f_cld, row.names = FALSE)
  cat("Wrote CLD letter table:", f_cld, "\n")
  cat("  Rows:", nrow(cld_table),
      "| Endpoints:", length(unique(cld_table$endpoint)), "\n\n")

  cat("Letter assignments by endpoint:\n")
  for (ep in unique(cld_table$endpoint)) {
    sub <- cld_table[cld_table$endpoint == ep,
                     c("treatment", "exposure", ".group", "art_component")]
    cat("\n  [", ep, "] (artlm:", unique(sub$art_component), ")\n")
    print(sub[, c("treatment", "exposure", ".group")], row.names = FALSE)
  }
}

# -- 9. Summary ---------------------------------------------------------------
cat("\n=== 03_patch_posthoc_contrasts.R COMPLETE ===\n")
cat("Outputs written:\n")
cat("  Full contrast table : ", f_contrasts, "\n")
cat("  CLD letter table    : ", f_cld,       "\n")
cat("\nNext steps:\n")
cat("  1. Update figures_manuscript.R to read 03_ethanol_cld_letters.csv\n")
cat("     instead of re-fitting ART models internally.\n")
cat("  2. Rerun figures_manuscript.R for final annotated figures.\n")
cat("  3. Rerun 07_reporting_tables_and_figures.Rmd.\n")
cat("  4. Update 12_clean_advisor_manuscript.md with final last_flux result.\n")
