## feature_analysis/weight_predictors.R
## given analysis results from correlation, anova, and feature importance
## return unified weight table ranking each predictor's impact on smoking
## combines scores by normalizing each to [0,1] and averaging

#' given a named numeric vector
#' return vector normalized to [0, 1]
normalize_scores <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

#' given correlation, anova, and importance dataframes
#' return dataframe with unified weight per feature sorted descending
#' saves to data/results/predictor_weights.csv
weight_predictors <- function(cor_scores, anova_df, importance_df, out_dir = "data/results") {
  features <- importance_df$feature

  cor_norm  <- normalize_scores(cor_scores[features])
  anova_norm <- normalize_scores(setNames(anova_df$f_stat, anova_df$feature)[features])
  imp_norm  <- normalize_scores(setNames(importance_df$importance, importance_df$feature)[features])

  weights <- data.frame(
    feature    = features,
    cor_weight = cor_norm,
    anova_weight = anova_norm,
    rf_weight  = imp_norm,
    combined   = rowMeans(cbind(cor_norm, anova_norm, imp_norm), na.rm = TRUE)
  )
  weights <- weights[order(-weights$combined), ]

  write.csv(weights, file.path(out_dir, "predictor_weights.csv"), row.names = FALSE)
  message("saved: ", file.path(out_dir, "predictor_weights.csv"))
  weights
}
