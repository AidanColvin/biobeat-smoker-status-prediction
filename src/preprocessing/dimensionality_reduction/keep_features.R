## dimensionality_reduction/keep_features.R
## given a dataframe and column names to keep
## return dataframe with only those columns

library(dplyr)

#' given a dataframe and a vector of column names
#' return dataframe containing only those columns
keep_features <- function(df, cols) {
  select(df, all_of(cols))
}