## data_cleaning/to_numeric.R
## given a dataframe and column names
## return dataframe with those columns cast to numeric

#' given a dataframe and a vector of column names
#' return dataframe with specified columns cast to numeric
to_numeric <- function(df, cols) {
  df[cols] <- lapply(df[cols], as.numeric)
  df
}