library(testthat)
source("src/cross_validate/cv_rf.R")

test_that("cv_rf returns a numeric error between 0 and 1", {
  df  <- iris
  df$Species <- ifelse(df$Species == "setosa", "yes", "no")
  err <- cv_rf(df, "Species", ntree = 50)
  expect_true(is.numeric(err))
  expect_gte(err, 0)
  expect_lte(err, 1)
})
