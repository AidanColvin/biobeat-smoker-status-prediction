library(testthat)
source("src/feature_analysis/anova_test.R")

test_that("run_anova returns dataframe with f_stat and p_value columns", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_anova(df, "smoking", out_dir = tempdir())
  expect_true(all(c("feature", "f_stat", "p_value") %in% names(out)))
})
