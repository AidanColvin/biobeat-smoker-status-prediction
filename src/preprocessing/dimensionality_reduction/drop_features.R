## dimensionality_reduction/drop_features.R
## given a dataframe and column names to remove
## return dataframe without those columns

library(dplyr)

#' given a dataframe and a vector of column names
#' return dataframe with those columns removed
drop_features <- function(df, cols) {
  select(df, -all_of(cols))
}