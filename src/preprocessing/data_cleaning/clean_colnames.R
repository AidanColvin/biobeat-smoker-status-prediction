## data_cleaning/clean_colnames.R
## given a dataframe
## return dataframe with column names sanitized for R formula use
## replaces spaces, parentheses, and special chars with underscores

#' given a dataframe
#' return dataframe with clean syntactic column names
clean_colnames <- function(df) {
  names(df) <- gsub("[^a-zA-Z0-9_]", "_", names(df))
  names(df) <- gsub("_+", "_", names(df))
  names(df) <- gsub("_$", "", names(df))
  df
}
