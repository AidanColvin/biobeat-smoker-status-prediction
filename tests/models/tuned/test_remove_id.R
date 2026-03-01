library(testthat)
source("src/models/tuned/remove_id.R")

test_that("remove_id drops id column", {
  df  <- data.frame(id = 1:5, a = rnorm(5), b = rnorm(5))
  out <- remove_id(df)
  expect_false("id" %in% names(out))
  expect_true("a" %in% names(out))
})

test_that("remove_id returns df unchanged if no id column", {
  df  <- data.frame(a = 1:3, b = 4:6)
  out <- remove_id(df)
  expect_equal(names(out), names(df))
})
