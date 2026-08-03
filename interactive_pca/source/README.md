# Interactive BT1 PCA

This directory builds the exploratory three-dimensional companion to the manuscript's canonical two-dimensional PCA figure.

The site does **not** fit or modify a PCA. It reads the saved canonical scores, loadings, variance summary, and provenance from `outputs/pca_canonical/`, validates their identity, and publishes them under `docs/pca3d/`.

## Locked specification

- BT1 only; 14 registered endpoints; blood glucose excluded
- complete-case n = 135 of 136; centered and scaled; no imputation
- PC1 = 23.3%, PC2 = 17.2%, PC3 = 10.3%
- cumulative PC1-PC3 = 50.8% after rounding

The interactive view is descriptive. It is not a test of ethanol or measurement-context effects, and apparent clusters are not inferential results.

## Build

From the repository root in R:

```r
source("interactive_pca/build_interactive_pca.R")
```

The script validates the canonical files and copies the public data bundle into `docs/pca3d/data/`. It never refits PCA. Plotly.js 3.1.0 and its license are pinned under `docs/pca3d/vendor/`, so the published and archived page does not depend on an external CDN.

Preview locally with:

```text
node interactive_pca/preview_server.js
```

Then open `http://127.0.0.1:8765/pca3d/`. Configure GitHub Pages to publish from `docs/`. Archive a manuscript-matched release with Zenodo before citing the artifact.
