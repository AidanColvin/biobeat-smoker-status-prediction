chi_sq_feature <- function(x, y) {
  result <- chisq.test(table(x, y))
  list(chi_sq = result$statistic, p_value = result$p.value)
}

run_chi_square <- function(df, response, out_dir = "data/results") {
  fac_cols <- names(df)[sapply(df, is.factor) & names(df) != response]
  if (length(fac_cols) == 0) { message("no factor columns found"); return(NULL) }
  results <- lapply(fac_cols, function(col) chi_sq_feature(df[[col]], df[[response]]))
  out     <- data.frame(
    feature = fac_cols,
    chi_sq  = sapply(results, `[[`, "chi_sq"),
    p_value = sapply(results, `[[`, "p_value")
  )
  out <- out[order(-out$chi_sq), ]
  write.csv(out, file.path(out_dir, "chi_square_results.csv"), row.names = FALSE)
  out
}
