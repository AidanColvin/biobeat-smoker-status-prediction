## data_transformation/min_max.R
## given a dataframe and optional column names
## return dataframe with numeric columns scaled to [0, 1]

library(dplyr)

#' given a numeric vector
#' return vector scaled to range [0, 1]
min_max_vec <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

#' given a dataframe and optional column names
#' return dataframe with specified numeric columns min-max normalized
min_max <- function(df, cols = NULL) {
  cols     <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], min_max_vec)
  df
}