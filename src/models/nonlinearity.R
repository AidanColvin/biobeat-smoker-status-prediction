library(boot)
library(splines)

best_poly_degree <- function(df, response, predictor, max_degree = 5, k = 10) {
  errors <- rep(0, max_degree)
  for (i in 1:max_degree) {
    fit      <- glm(as.formula(paste(response, "~ poly(", predictor, ",", i, ")")), data = df, family = binomial)
    errors[i] <- cv.glm(df, fit, K = k)$delta[1]
  }
  which.min(errors)
}

run_spline <- function(df, response, predictor, df_spline = 4) {
  glm(as.formula(paste(response, "~ ns(", predictor, ", df =", df_spline, ")")), data = df, family = binomial)
}
