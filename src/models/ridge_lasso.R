## models/ridge_lasso.R
## given train data and response name
## return cv-tuned ridge and lasso models
## uses glmnet with alpha=0 (ridge) and alpha=1 (lasso)

library(glmnet) # glmnet, cv.glmnet

#' given a dataframe and response name
#' return list with cv ridge model and best lambda
run_ridge <- function(df, response) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = 0, family = "binomial")
  message("ridge best lambda: ", round(cv_fit$lambda.min, 5))
  list(model = cv_fit, lambda = cv_fit$lambda.min)
}

#' given a dataframe and response name
#' return list with cv lasso model, best lambda, and nonzero features
run_lasso <- function(df, response) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = 1, family = "binomial")
  coefs  <- coef(cv_fit, s = "lambda.min")
  kept   <- rownames(coefs)[coefs[, 1] != 0]
  message("lasso kept ", length(kept), " features at lambda.min")
  list(model = cv_fit, lambda = cv_fit$lambda.min, kept_features = kept)
}
