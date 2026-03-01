## data_transformation/standardize.R
## given a dataframe and optional column names
## return dataframe with numeric columns z-score standardized

library(dplyr)

#' given a dataframe and optional column names
#' return dataframe with specified numeric columns standardized to mean 0 sd 1
standardize <- function(df, cols = NULL) {
  cols  <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], scale)
  df
}