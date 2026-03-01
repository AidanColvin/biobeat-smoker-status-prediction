library(testthat)
source("src/train/train_qda.R")

test_that("train_qda returns a qda object", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", 1, 0)
  fit <- train_qda(df, "Species")
  expect_s3_class(fit, "qda")
})
