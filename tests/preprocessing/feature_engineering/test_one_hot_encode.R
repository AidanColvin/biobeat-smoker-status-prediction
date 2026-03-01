library(testthat)
source("src/preprocessing/feature_engineering/one_hot_encode.R")

test_that("one_hot_encode expands a factor column into binary columns", {
  df  <- data.frame(color = as.factor(c("red", "blue", "red")))
  out <- one_hot_encode(df, "color")
  expect_true(any(grepl("color", names(out))))
  expect_true(all(unlist(out) %in% c(0, 1)))
})
