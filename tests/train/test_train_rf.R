library(testthat)
source("src/train/train_rf.R")

test_that("train_rf returns a randomForest object", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", "yes", "no")
  fit <- train_rf(df, "Species", ntree = 50)
  expect_s3_class(fit, "randomForest")
})
