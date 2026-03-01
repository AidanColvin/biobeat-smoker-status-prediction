## cross_validate/cv_lda.R
## given train data and response name
## return k-fold cv classification error for lda

library(MASS) # lda

source("src/cross_validate/cv_utils.R")

K_FOLDS <- 10

#' given a dataframe and response name
#' return mean k-fold cv classification error for lda
cv_lda <- function(df, response, k = K_FOLDS) {
  folds  <- make_folds(nrow(df), k)
  errors <- rep(0, k)

  for (i in 1:k) {
    fit       <- lda(as.formula(paste(response, "~ .")), data = df[folds != i, ])
    preds     <- predict(fit, df[folds == i, ])$class
    errors[i] <- classification_error(preds, df[folds == i, ][[response]])
  }

  cv_error <- mean(errors)
  message("lda cv error: ", round(cv_error, 4))
  cv_error
}