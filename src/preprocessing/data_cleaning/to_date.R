## data_cleaning/to_date.R
## given a dataframe, column names, and a date format string
## return dataframe with those columns cast to Date

#' given a dataframe, a vector of column names, and a date format string
#' return dataframe with specified columns cast to Date
to_date <- function(df, cols, fmt = "%Y-%m-%d") {
  df[cols] <- lapply(df[cols], function(x) as.Date(x, format = fmt))
  df
}