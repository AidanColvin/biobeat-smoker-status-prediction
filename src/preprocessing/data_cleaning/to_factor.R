## data_cleaning/to_factor.R
## given a dataframe and column names
## return dataframe with those columns cast to factor

#' given a dataframe and a vector of column names
#' return dataframe with specified columns cast to factor
to_factor <- function(df, cols) {
  df[cols] <- lapply(df[cols], as.factor)
  df
}