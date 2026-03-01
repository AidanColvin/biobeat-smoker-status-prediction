## models/pcr.R
## given train data and response name
## return cv-tuned principal components regression model
## uses pls::pcr with cross validation to find optimal number of components

library(pls) # pcr

#' given a dataframe and response name
#' return fitted pcr model with cv-selected number of components
#' saves variance explained plot to data/results/pcr_variance.png
run_pcr <- function(df, response, out_dir = "data/results") {
  df[[response]] <- as.numeric(df[[response]])
  fit <- pcr(
    as.formula(paste(response, "~ .")),
    data       = df,
    scale      = TRUE,
    validation = "CV"
  )

  best_ncomp <- which.min(fit$validation$PRESS)
  message("pcr best components: ", best_ncomp)

  png(file.path(out_dir, "pcr_variance.png"), width = 900, height = 600)
  validationplot(fit, val.type = "MSEP", main = "pcr: MSEP by components")
  dev.off()

  message("saved: ", file.path(out_dir, "pcr_variance.png"))
  list(model = fit, best_ncomp = best_ncomp)
}
