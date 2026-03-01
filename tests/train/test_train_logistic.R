library(testthat)
source("src/train/train_logistic.R")

test_that("train_logistic returns a glm object", {
  data(Auto, package = "ISLR")
  Auto$high_mpg <- as.integer(Auto$mpg > median(Auto$mpg))
  fit <- train_logistic(Auto, "high_mpg", degree = 2)
  expect_s3_class(fit, "glm")
})
