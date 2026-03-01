library(dplyr)

#' given a dataframe and optional column names
#' return dataframe with log1p applied to numeric columns
#' uses log1p to safely handle zeros
log_transform <- function(df, cols = NULL) {
  cols <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], log1p)
  df
}