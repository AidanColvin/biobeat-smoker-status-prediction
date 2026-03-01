#' given a dataframe, a vector of column names, and a target type
#' return dataframe with columns converted to the target type
#' type: "numeric", "factor", "character", "date"
convert_types <- function(df, cols, type, date_format = "%Y-%m-%d") {
  convert_fn <- switch(type,
    numeric   = as.numeric,
    factor    = as.factor,
    character = as.character,
    date      = function(x) as.Date(x, format = date_format),
    stop("Unknown type: ", type)
  )
  df[cols] <- lapply(df[cols], convert_fn)
  df
}