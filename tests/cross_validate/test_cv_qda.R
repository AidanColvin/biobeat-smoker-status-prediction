library(testthat)
source("src/cross_validate/cv_qda.R")

test_that("cv_qda returns a numeric error between 0 and 1", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", 1, 0)
  err <- cv_qda(df, "Species")
  expect_true(is.numeric(err))
  expect_gte(err, 0)
  expect_lte(err, 1)
})
