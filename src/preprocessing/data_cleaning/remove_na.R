## data_cleaning/remove_na.R
## given a dataframe
## return dataframe with all rows containing NA removed

#' given a dataframe
#' return dataframe with NA rows removed
remove_na <- function(df) {
  na.omit(df)
}