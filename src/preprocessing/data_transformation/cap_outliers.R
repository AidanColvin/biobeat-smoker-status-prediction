## data_transformation/cap_outliers.R
## given a dataframe, optional column names, and percentile bounds
## return dataframe with outliers capped at lower and upper percentile

#' given a numeric vector and percentile bounds
#' return vector with values capped at those percentiles
cap_vec <- function(x, lower = 0.05, upper = 0.95) {
  bounds <- quantile(x, probs = c(lower, upper), na.rm = TRUE)
  pmax(pmin(x, bounds[2]), bounds[1])
}

#' given a dataframe, optional column names, and percentile bounds
#' return dataframe with outliers capped per column
cap_outliers <- function(df, cols = NULL, lower = 0.05, upper = 0.95) {
  cols     <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], cap_vec, lower = lower, upper = upper)
  df
}