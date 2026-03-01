## feature_analysis/mutual_info.R
## given preprocessed train data and response name
## return mutual information score per predictor using discretization
## mutual info captures nonlinear relationships correlation misses

library(infotheo) # mutinformation, discretize

#' given a dataframe and response name
#' return named numeric vector of mutual info scores sorted descending
#' saves results to data/results/mutual_info.csv
run_mutual_info <- function(df, response, out_dir = "data/results") {
  predictors <- setdiff(names(df), response)
  disc_df    <- discretize(df[, predictors])
  disc_y     <- discretize(df[[response]])

  scores <- sapply(predictors, function(col) {
    mutinformation(disc_df[[col]], disc_y[[1]])
  })
  sorted <- sort(scores, decreasing = TRUE)

  write.csv(
    data.frame(feature = names(sorted), mutual_info = sorted),
    file.path(out_dir, "mutual_info.csv"), row.names = FALSE
  )
  message("saved: ", file.path(out_dir, "mutual_info.csv"))
  sorted
}
