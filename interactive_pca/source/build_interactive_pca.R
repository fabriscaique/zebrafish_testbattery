# Validate and publish saved canonical PCA outputs. This script never refits PCA.
source_dir <- file.path("outputs", "pca_canonical")
target_dir <- file.path("docs", "pca3d", "data")
files <- c(scores="pca_scores.csv", loadings="pca_loadings.csv", variance="pca_variance_explained.csv", provenance="pca_model_provenance.json")
paths <- file.path(source_dir, files)
if (any(!file.exists(paths))) stop("Missing canonical PCA file(s): ", paste(paths[!file.exists(paths)], collapse=", "))

scores <- read.csv(paths[["scores"]], check.names=FALSE)
loadings <- read.csv(paths[["loadings"]], check.names=FALSE)
variance <- read.csv(paths[["variance"]], check.names=FALSE)
if (!all(c("fish_id","treatment","exposure","PC1","PC2","PC3") %in% names(scores))) stop("Required score fields missing.")
if (!all(c("short_label","domain","PC1","PC2","PC3") %in% names(loadings))) stop("Required loading fields missing.")
if (nrow(scores) != 135L) stop("Expected 135 scores; found ", nrow(scores))
if (nrow(loadings) != 14L) stop("Expected 14 loadings; found ", nrow(loadings))

expected_var <- c(PC1=0.23336713890878127, PC2=0.17234661817713600, PC3=0.10251274720527978)
observed_var <- setNames(variance$proportion_variance[match(names(expected_var), variance$component)], names(expected_var))
if (anyNA(observed_var) || any(abs(observed_var-expected_var)>1e-10)) stop("Variance values differ from the locked PCA.")

expected_endpoints <- sort(c("time_bright","mtpc","first_choice_binary","latency","num_changes","dist_total","vel_mean","mov_total","stratum_pref","resistance_index","last_flux","attempts","time_in_last_flux","condition_factor"))
endpoint_col <- names(loadings)[1]
if (!identical(sort(as.character(loadings[[endpoint_col]])), expected_endpoints)) stop("Endpoint set differs from the locked PCA.")

dir.create(target_dir, recursive=TRUE, showWarnings=FALSE)
if (!all(file.copy(paths, file.path(target_dir, files), overwrite=TRUE))) stop("Could not publish all canonical files.")
message("Validated PCA data published to ", target_dir)

