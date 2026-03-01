library(testthat)
source("src/preprocessing/dimensionality_reduction/keep_features.R")

test_that("keep_features retains only specified columns", {
  df  <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  out <- keep_features(df, c("a", "c"))
  expect_equal(sort(names(out)), c("a", "c"))
})
