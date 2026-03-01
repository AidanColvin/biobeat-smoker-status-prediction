library(testthat)
source("src/preprocessing/dimensionality_reduction/drop_features.R")

test_that("drop_features removes specified columns", {
  df  <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  out <- drop_features(df, c("a", "b"))
  expect_equal(names(out), "c")
})
