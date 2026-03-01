library(testthat)
source("src/evaluate/eval_combinations.R")

test_that("average_probs averages correctly", {
  p1  <- c(0.2, 0.8)
  p2  <- c(0.4, 0.6)
  out <- average_probs(list(p1, p2))
  expect_equal(out, c(0.3, 0.7))
})

test_that("majority_vote returns correct labels", {
  p1  <- c(1, 0, 1)
  p2  <- c(1, 1, 0)
  p3  <- c(0, 0, 1)
  out <- majority_vote(list(p1, p2, p3))
  expect_equal(out, c(1, 0, 1))
})
