## feature_analysis/anova_test.R
## given preprocessed train data and response name
## return anova f-statistic and p-value per numeric predictor
## high f-stat = predictor separates smoking classes well

#' given a numeric predictor vector and binary response vector
#' return list with f statistic and p value
anova_feature <- function(x, y) {
  fit    <- aov(x ~ as.factor(y))
  result <- summary(fit)[[1]]
  list(f_stat = result[["F value"]][1], p_value = result[["Pr(>F)"]][1])
}

#' given a dataframe and response name
#' return dataframe of f_stat and p_value per predictor sorted by f_stat
#' saves results to data/results/anova_results.csv
run_anova <- function(df, response, out_dir = "data/results") {
  num_cols <- names(df)[sapply(df, is.numeric) & names(df) != response]
  results  <- lapply(num_cols, function(col) anova_feature(df[[col]], df[[response]]))
  out      <- data.frame(
    feature = num_cols,
    f_stat  = sapply(results, `[[`, "f_stat"),
    p_value = sapply(results, `[[`, "p_value")
  )
  out <- out[order(-out$f_stat), ]
  write.csv(out, file.path(out_dir, "anova_results.csv"), row.names = FALSE)
  message("saved: ", file.path(out_dir, "anova_results.csv"))
  out
}
