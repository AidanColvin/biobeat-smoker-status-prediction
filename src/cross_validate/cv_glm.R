## cross_validate/cv_glm.R
## given train data and response name
## return best polynomial degree and cv error vector for logistic regression

library(boot) # cv.glm

source("src/cross_validate/cv_utils.R")

K_FOLDS    <- 10
MAX_DEGREE <- 10

#' given a dataframe, response name, and polynomial degree
#' return 10-fold cv error for logistic regression at that degree
cv_glm_degree <- function(df, response, degree, k = K_FOLDS) {
  formula <- as.formula(paste(response, "~ poly(horsepower,", degree, ")"))
  fit     <- glm(formula, data = df, family = binomial)
  cv.glm(df, fit, K = k)$delta[1]
}

#' given a dataframe and response name
#' return list with cv error vector and best degree
#' plots cv error curve with best degree marked
cv_glm <- function(df, response, max_degree = MAX_DEGREE, k = K_FOLDS) {
  errors <- rep(0, max_degree)
  for (i in 1:max_degree) errors[i] <- cv_glm_degree(df, response, i, k)

  best <- which.min(errors)
  plot(1:max_degree, errors, pch = 16, cex = 0.5, type = "b",
       xlab = "polynomial degree", ylab = paste0(k, "-fold CV error"),
       main = "logistic regression: cv error by degree")
  abline(v = best, lty = 2)

  message("glm best degree: ", best)
  list(cv_errors = errors, best_degree = best)
}