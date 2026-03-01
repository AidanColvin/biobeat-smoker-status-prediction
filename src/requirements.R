## requirements.R
## install all libraries needed for preprocessing pipeline
## run once before using any other scripts

packages <- c(
  # data loading & manipulation
  "readr",    # read_csv — fast CSV loading
  "dplyr",    # data manipulation (filter, mutate, select, distinct)
  "tidyr",    # reshaping (pivot_longer, pivot_wider)

  # preprocessing
  "recipes",  # tidy preprocessing pipelines (one-hot, scaling, etc.)
  "mice",     # multiple imputation for missing values

  # dimensionality reduction
  "stats",    # prcomp — PCA (base R, listed for clarity)

  # utilities
  "stringr",  # string cleaning
  "lubridate" # date parsing
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

invisible(lapply(packages, install_if_missing))
message("all packages ready")