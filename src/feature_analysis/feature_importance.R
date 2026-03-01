## feature_analysis/feature_importance.R
## given preprocessed train data and response name
## return random forest feature importance scores
## uses mean decrease gini as proxy for predictor impact on smoking

library(randomForest)

#' given a dataframe and response name
#' return dataframe of feature importance sorted by MeanDecreaseGini
#' saves plot and csv to data/results/
run_feature_importance <- function(df, response, ntree = 500, out_dir = "data/results") {
  df[[response]] <- as.factor(df[[response]])
  fit     <- randomForest(as.formula(paste(response, "~ .")), data = df,
                          ntree = ntree, importance = TRUE)
  imp     <- importance(fit)
  imp_df  <- data.frame(feature = rownames(imp), importance = imp[, "MeanDecreaseGini"])
  imp_df  <- imp_df[order(-imp_df$importance), ]

  write.csv(imp_df, file.path(out_dir, "feature_importance.csv"), row.names = FALSE)

  png(file.path(out_dir, "feature_importance.png"), width = 900, height = 600)
  varImpPlot(fit, main = "random forest feature importance: smoking")
  dev.off()

  message("saved: ", file.path(out_dir, "feature_importance.csv"))
  imp_df
}
