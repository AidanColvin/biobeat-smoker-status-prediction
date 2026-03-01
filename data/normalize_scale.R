library(dplyr)

#' given a dataframe and optional column names
#' return dataframe with numeric columns standardized (z-score)
standardize <- function(df, cols = NULL) {
  cols <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], scale)
  df
}

#' given a dataframe and optional column names
#' return dataframe with numeric columns min-max normalized to [0, 1]
min_max_normalize <- function(df, cols = NULL) {
  cols <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], function(x) (x - min(x)) / (max(x) - min(x)))
  df
}