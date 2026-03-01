## feature_analysis/chi_square_test.R
## given preprocessed train data and response name
## return chi-square statistic and p-value for factor predictors vs response
## tests independence between each categorical feature and smoking status

#' given a factor predictor vector and binary response vector
#' return list with chi_sq statistic and p value
chi_sq_feature <- function(x, y) {
  tbl    <- table(x, y)
  result <- chisq.test(tbl)
  list(chi_sq = result$statistic, p_value = result$p.value)
}

#' given a dataframe and response name
#' return dataframe of chi_sq and p_value per factor predictor sorted by chi_sq
#' saves results to data/results/chi_square_results.csv
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
  message("saved: ", file.path(out_dir, "chi_square_results.csv"))
  out
}
