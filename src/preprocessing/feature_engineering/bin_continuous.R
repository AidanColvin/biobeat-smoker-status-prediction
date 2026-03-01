## feature_engineering/bin_continuous.R
## given a dataframe, a column name, breakpoints, and labels
## return dataframe with a new binned column appended as <col>_bin

#' given a dataframe, a column name, breakpoints, and bin labels
#' return dataframe with new column <col>_bin containing bin assignments
bin_continuous <- function(df, col, breaks, labels) {
  df[[paste0(col, "_bin")]] <- cut(df[[col]], breaks = breaks, labels = labels, include.lowest = TRUE)
  df
}