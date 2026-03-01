## models/tuned/remove_id.R
## given a dataframe
## return dataframe with id column removed
## id is a row identifier not a clinical predictor

#' given a dataframe
#' return dataframe without id column
remove_id <- function(df) {
  df[, names(df) != "id", drop = FALSE]
}
