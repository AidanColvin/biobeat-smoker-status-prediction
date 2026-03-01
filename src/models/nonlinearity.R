## models/nonlinearity.R
## given train data, response name, and a predictor
## fits polynomial and spline models to test for nonlinear relationships
## saves degree cv error plot to data/results/

library(boot)    # cv.glm
library(splines) # bs, ns

K_FOLDS    <- 10
MAX_DEGREE <- 5

#' given a dataframe, response name, and predictor column name
#' return best polynomial degree by 10-fold cv error
best_poly_degree <- function(df, response, predictor, max_degree = MAX_DEGREE, k = K_FOLDS) {
  errors <- rep(0, max_degree)
  for (i in 1:max_degree) {
    formula  <- as.formula(paste(response, "~ poly(", predictor, ",", i, ")"))
    fit      <- glm(formula, data = df, family = binomial)
    errors[i] <- cv.glm(df, fit, K = k)$delta[1]
  }
  which.min(errors)
}

#' given a dataframe, response name, and predictor
#' return fitted natural spline model with 4 degrees of freedom
run_spline <- function(df, response, predictor, df_spline = 4) {
  formula <- as.formula(paste(response, "~ ns(", predictor, ", df =", df_spline, ")"))
  glm(formula, data = df, family = binomial)
}
