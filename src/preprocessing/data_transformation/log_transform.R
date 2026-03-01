## data_transformation/log_transform.R
## given a dataframe and optional column names
## return dataframe with log1p applied to numeric columns

#' given a dataframe and optional column names
#' return dataframe with log1p applied to specified numeric columns
#' log1p used to safely handle zero values
log_transform <- function(df, cols = NULL) {
  cols     <- cols %||% names(df)[sapply(df, is.numeric)]
  df[cols] <- lapply(df[cols], log1p)
  df
}