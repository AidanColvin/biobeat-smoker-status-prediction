## data_cleaning/impute_median.R
## given a dataframe
## return dataframe with numeric NAs replaced by column median

library(dplyr)

#' given a dataframe
#' return dataframe with numeric NAs filled with column median
impute_median <- function(df) {
  df %>% mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))
}