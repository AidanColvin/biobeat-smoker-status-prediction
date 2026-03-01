library(dplyr)
library(mice)

#' given a dataframe and a strategy
#' return dataframe with NAs handled
#' strategy: "remove", "mean", "median", "mice"
handle_missing <- function(df, strategy = "mean") {
  if (strategy == "remove") return(na.omit(df))
  if (strategy == "mice")   return(complete(mice(df, m = 1, printFlag = FALSE)))

  df %>% mutate(across(where(is.numeric), ~ ifelse(
    is.na(.),
    if (strategy == "mean") mean(., na.rm = TRUE) else median(., na.rm = TRUE),
    .
  )))
}