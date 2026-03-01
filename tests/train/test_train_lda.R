library(testthat)
source("src/train/train_lda.R")

test_that("train_lda returns an lda object", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", 1, 0)
  fit <- train_lda(df, "Species")
  expect_s3_class(fit, "lda")
})
