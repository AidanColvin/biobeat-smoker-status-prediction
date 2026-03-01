## data_cleaning/remove_duplicates.R
## given a dataframe
## return dataframe with duplicate rows removed

library(dplyr)

#' given a dataframe
#' return dataframe with duplicate rows removed
remove_duplicates <- function(df) {
  distinct(df)
}