library(testthat)
source("src/cross_validate/cv_utils.R")

test_that("make_folds returns correct length and fold range", {
  folds <- make_folds(100, k = 10)
  expect_equal(length(folds), 100)
  expect_true(all(folds %in% 1:10))
})

test_that("classification_error returns 0 when all correct", {
  expect_equal(classification_error(c("a", "b"), c("a", "b")), 0)
})

test_that("classification_error returns 1 when all wrong", {
  expect_equal(classification_error(c("a", "a"), c("b", "b")), 1)
})
