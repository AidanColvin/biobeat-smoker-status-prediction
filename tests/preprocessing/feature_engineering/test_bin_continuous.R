library(testthat)
source("src/preprocessing/feature_engineering/bin_continuous.R")

test_that("bin_continuous creates a new <col>_bin column", {
  df  <- data.frame(age = c(15, 35, 65))
  out <- bin_continuous(df, "age", breaks = c(0, 25, 55, 100), labels = c("young", "mid", "senior"))
  expect_true("age_bin" %in% names(out))
  expect_equal(as.character(out$age_bin), c("young", "mid", "senior"))
})
