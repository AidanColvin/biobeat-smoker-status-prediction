library(glmnet)

run_ridge <- function(df, response) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = 0, family = "binomial")
  list(model = cv_fit, lambda = cv_fit$lambda.min)
}

run_lasso <- function(df, response) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = 1, family = "binomial")
  coefs  <- coef(cv_fit, s = "lambda.min")
  kept   <- rownames(coefs)[coefs[, 1] != 0]
  list(model = cv_fit, lambda = cv_fit$lambda.min, kept_features = kept)
}
