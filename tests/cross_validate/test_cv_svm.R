library(testthat)
source("src/cross_validate/cv_svm.R")

test_that("cv_svm returns a numeric error between 0 and 1", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", "yes", "no")
  err <- cv_svm(df, "Species")
  expect_true(is.numeric(err))
  expect_gte(err, 0)
  expect_lte(err, 1)
})
