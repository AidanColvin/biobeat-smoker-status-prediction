library(testthat)
source("src/train/train_svm.R")

test_that("train_svm returns an svm object", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", "yes", "no")
  fit <- train_svm(df, "Species")
  expect_s3_class(fit, "svm")
})
