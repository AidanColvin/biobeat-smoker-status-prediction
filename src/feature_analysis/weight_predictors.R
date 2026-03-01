normalize_scores <- function(x) {
  rng <- max(x) - min(x)
  if (rng == 0) return(rep(0, length(x)))
  (x - min(x)) / rng
}

weight_predictors <- function(cor_scores, anova_df, importance_df, out_dir = "data/results") {
  features   <- importance_df$feature
  cor_norm   <- normalize_scores(cor_scores[features])
  anova_norm <- normalize_scores(setNames(anova_df$f_stat, anova_df$feature)[features])
  imp_norm   <- normalize_scores(setNames(importance_df$importance, importance_df$feature)[features])
  weights <- data.frame(
    feature      = features,
    cor_weight   = cor_norm,
    anova_weight = anova_norm,
    rf_weight    = imp_norm,
    combined     = rowMeans(cbind(cor_norm, anova_norm, imp_norm), na.rm = TRUE)
  )
  weights <- weights[order(-weights$combined), ]
  write.csv(weights, file.path(out_dir, "predictor_weights.csv"), row.names = FALSE)
  weights
}
