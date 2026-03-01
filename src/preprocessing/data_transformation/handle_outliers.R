#' given a numeric vector and bounds
#' return vector with values capped at lower and upper percentile
cap_outliers <- function(x, lower = 0.05, upper = 0.95) {
  bounds <- quantile(x, probs = c(lower, upper), na.rm = TRUE)
  pmax(pmin(x, bounds[2]), bounds[1])
}

#' given a dataframe and optional column names
#' return dataframe with outliers capped per column
cap_outliers_df <- function(df, cols = NULL, lower = 0.05, upper = 0.95) {
  cols <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], cap_outliers, lower = lower, upper = upper)
  df
}