library(randomForest)

run_feature_importance <- function(df, response, ntree = 500, out_dir = "data/results") {
  df[[response]] <- as.factor(df[[response]])
  fit    <- randomForest(as.formula(paste(response, "~ .")), data = df, ntree = ntree, importance = TRUE)
  imp    <- importance(fit)
  imp_df <- data.frame(feature = rownames(imp), importance = imp[, "MeanDecreaseGini"])
  imp_df <- imp_df[order(-imp_df$importance), ]
  write.csv(imp_df, file.path(out_dir, "feature_importance.csv"), row.names = FALSE)
  png(file.path(out_dir, "feature_importance.png"), width = 900, height = 600)
  varImpPlot(fit, main = "random forest feature importance")
  dev.off()
  imp_df
}
