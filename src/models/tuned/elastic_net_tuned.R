## models/tuned/elastic_net_tuned.R
## given train data and response name
## return best elastic net by searching alpha in [0, 0.25, 0.5, 0.75, 1]
## searches both alpha and lambda via 10-fold cv

library(glmnet)

#' given a dataframe, response name, and alpha value
#' return 10-fold cv auc for elastic net at that alpha
cv_elastic_alpha <- function(df, response, alpha_val, k = 10) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = alpha_val, family = "binomial", type.measure = "auc", nfolds = k)
  max(cv_fit$cvm)
}

#' given a dataframe and response name
#' return fitted elastic net at best alpha from grid search
tune_elastic_net <- function(df, response, k = 10) {
  alphas  <- c(0, 0.25, 0.5, 0.75, 1)
  message("searching alpha: ", paste(alphas, collapse = ", "))
  aucs    <- sapply(alphas, function(a) {
    message("  cv alpha=", a, "...")
    cv_elastic_alpha(df, response, a, k)
  })
  best_alpha <- alphas[which.max(aucs)]
  message("best alpha: ", best_alpha, " (cv auc: ", round(max(aucs), 4), ")")
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = best_alpha, family = "binomial", type.measure = "auc", nfolds = k)
  list(model = cv_fit, lambda = cv_fit$lambda.min, alpha = best_alpha)
}
