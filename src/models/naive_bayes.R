library(e1071)

run_naive_bayes <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  naiveBayes(as.formula(paste(response, "~ .")), data = df)
}

predict_naive_bayes <- function(fit, test) {
  predict(fit, newdata = test)
}
