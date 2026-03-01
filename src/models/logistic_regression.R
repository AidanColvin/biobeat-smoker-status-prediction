run_logistic <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  glm(as.formula(paste(response, "~ .")), data = df, family = binomial)
}

predict_logistic <- function(fit, test, threshold = 0.5) {
  probs <- predict(fit, newdata = test, type = "response")
  ifelse(probs >= threshold, 1, 0)
}
