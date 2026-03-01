library(testthat)
source("src/models/knn.R")

test_that("run_knn returns predictions of correct length", {
  train <- data.frame(a = rnorm(40), b = rnorm(40), smoking = rbinom(40, 1, 0.5))
  test  <- data.frame(a = rnorm(10), b = rnorm(10), smoking = rbinom(10, 1, 0.5))
  preds <- run_knn(train, test, "smoking", k = 3)
  expect_equal(length(preds), 10)
})
