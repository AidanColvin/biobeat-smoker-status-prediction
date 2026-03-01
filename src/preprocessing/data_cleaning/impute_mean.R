## data_cleaning/impute_mean.R
## given a dataframe
## return dataframe with numeric NAs replaced by column mean

library(dplyr)

#' given a dataframe
#' return dataframe with numeric NAs filled with column mean
impute_mean <- function(df) {
  df %>% mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))
}