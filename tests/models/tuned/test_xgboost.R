library(testthat)
source("src/models/tuned/xgboost_model.R")

test_that("make_xgb_matrix returns xgb.DMatrix", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  mat <- make_xgb_matrix(df, "smoking")
  expect_s4_class(mat, "xgb.DMatrix")
})

test_that("predict_xgboost returns probabilities between 0 and 1", {
  df    <- data.frame(a = rnorm(100), b = rnorm(100), smoking = rbinom(100, 1, 0.5))
  fit   <- tune_xgboost(df, "smoking", max_rounds = 10, k = 3)
  preds <- predict_xgboost(fit, df, "smoking")
  expect_true(all(preds >= 0 & preds <= 1))
})
