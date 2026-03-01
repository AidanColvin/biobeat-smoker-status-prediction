packages <- c(
  "readr", "dplyr", "tidyr", "recipes", "mice",
  "class", "e1071", "MASS", "randomForest",
  "glmnet", "pls", "boot", "splines", "infotheo",
  "stringr", "lubridate", "pROC"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE, repos = "https://cran.rstudio.com/")
  }
}

invisible(lapply(packages, install_if_missing))
message("all packages ready")
