library(dplyr)

#' given a dataframe and a vector of columns to drop
#' return dataframe without the specified columns
drop_features <- function(df, cols) {
  select(df, -all_of(cols))
}

#' given a dataframe and a vector of columns to keep
#' return dataframe with only the specified columns
keep_features <- function(df, cols) {
  select(df, all_of(cols))
}