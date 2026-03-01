library(testthat)
source("src/cross_validate/cv_glm.R")

test_that("cv_glm returns best_degree in range 1:max_degree", {
  data(Auto, package = "ISLR")
  Auto$high_mpg <- as.integer(Auto$mpg > median(Auto$mpg))
  result <- cv_glm(Auto, "high_mpg", max_degree = 5)
  expect_true(result$best_degree %in% 1:5)
  expect_equal(length(result$cv_errors), 5)
})
