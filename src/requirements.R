## requirements.R
## install all libraries needed for full pipeline
## run once before using any other scripts

packages <- c(
  "readr", "dplyr", "tidyr",
  "recipes", "mice",
  "class",        # knn
  "e1071",        # svm, naive bayes
  "MASS",         # lda, qda
  "randomForest", # feature importance, rf
  "glmnet",       # ridge, lasso
  "pls",          # pcr
  "boot",         # cv.glm, bootstrap
  "splines",      # ns, bs
  "infotheo",     # mutual information
  "stringr", "lubridate"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg, dependencies = TRUE)
}

invisible(lapply(packages, install_if_missing))
message("all packages ready")
