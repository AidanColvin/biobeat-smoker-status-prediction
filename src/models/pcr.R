library(pls)

run_pcr <- function(df, response, out_dir = "data/results") {
  df[[response]] <- as.numeric(df[[response]])
  fit        <- pcr(as.formula(paste(response, "~ .")), data = df, scale = TRUE, validation = "CV")
  best_ncomp <- which.min(fit$validation$PRESS)
  png(file.path(out_dir, "pcr_variance.png"), width = 900, height = 600)
  validationplot(fit, val.type = "MSEP", main = "pcr: MSEP by components")
  dev.off()
  list(model = fit, best_ncomp = best_ncomp)
}
