#!/bin/bash
set -e

mkdir -p src/feature_analysis src/models data/results tests/feature_analysis tests/models

cat > src/feature_analysis/correlation.R << 'REOF'
library(dplyr)

correlate_features <- function(df, response, out_dir = "data/results") {
  num_cols <- names(df)[sapply(df, is.numeric) & names(df) != response]
  cors     <- sapply(num_cols, function(col) cor(df[[col]], as.numeric(df[[response]]), use = "complete.obs"))
  sorted   <- sort(abs(cors), decreasing = TRUE)
  png(file.path(out_dir, "correlation.png"), width = 900, height = 600)
  barplot(sorted, las = 2, main = "absolute correlation with smoking", ylab = "abs(correlation)", col = "steelblue")
  dev.off()
  write.csv(data.frame(feature = names(sorted), correlation = sorted), file.path(out_dir, "correlation.csv"), row.names = FALSE)
  sorted
}
REOF

cat > src/feature_analysis/anova_test.R << 'REOF'
anova_feature <- function(x, y) {
  fit    <- aov(x ~ as.factor(y))
  result <- summary(fit)[[1]]
  list(f_stat = result[["F value"]][1], p_value = result[["Pr(>F)"]][1])
}

run_anova <- function(df, response, out_dir = "data/results") {
  num_cols <- names(df)[sapply(df, is.numeric) & names(df) != response]
  results  <- lapply(num_cols, function(col) anova_feature(df[[col]], df[[response]]))
  out      <- data.frame(
    feature = num_cols,
    f_stat  = sapply(results, `[[`, "f_stat"),
    p_value = sapply(results, `[[`, "p_value")
  )
  out <- out[order(-out$f_stat), ]
  write.csv(out, file.path(out_dir, "anova_results.csv"), row.names = FALSE)
  out
}
REOF

cat > src/feature_analysis/chi_square_test.R << 'REOF'
chi_sq_feature <- function(x, y) {
  result <- chisq.test(table(x, y))
  list(chi_sq = result$statistic, p_value = result$p.value)
}

run_chi_square <- function(df, response, out_dir = "data/results") {
  fac_cols <- names(df)[sapply(df, is.factor) & names(df) != response]
  if (length(fac_cols) == 0) { message("no factor columns found"); return(NULL) }
  results <- lapply(fac_cols, function(col) chi_sq_feature(df[[col]], df[[response]]))
  out     <- data.frame(
    feature = fac_cols,
    chi_sq  = sapply(results, `[[`, "chi_sq"),
    p_value = sapply(results, `[[`, "p_value")
  )
  out <- out[order(-out$chi_sq), ]
  write.csv(out, file.path(out_dir, "chi_square_results.csv"), row.names = FALSE)
  out
}
REOF

cat > src/feature_analysis/mutual_info.R << 'REOF'
library(infotheo)

run_mutual_info <- function(df, response, out_dir = "data/results") {
  predictors <- setdiff(names(df), response)
  disc_df    <- discretize(df[, predictors])
  disc_y     <- discretize(df[[response]])
  scores     <- sapply(predictors, function(col) mutinformation(disc_df[[col]], disc_y[[1]]))
  sorted     <- sort(scores, decreasing = TRUE)
  write.csv(data.frame(feature = names(sorted), mutual_info = sorted), file.path(out_dir, "mutual_info.csv"), row.names = FALSE)
  sorted
}
REOF

cat > src/feature_analysis/feature_importance.R << 'REOF'
library(randomForest)

run_feature_importance <- function(df, response, ntree = 500, out_dir = "data/results") {
  df[[response]] <- as.factor(df[[response]])
  fit    <- randomForest(as.formula(paste(response, "~ .")), data = df, ntree = ntree, importance = TRUE)
  imp    <- importance(fit)
  imp_df <- data.frame(feature = rownames(imp), importance = imp[, "MeanDecreaseGini"])
  imp_df <- imp_df[order(-imp_df$importance), ]
  write.csv(imp_df, file.path(out_dir, "feature_importance.csv"), row.names = FALSE)
  png(file.path(out_dir, "feature_importance.png"), width = 900, height = 600)
  varImpPlot(fit, main = "random forest feature importance")
  dev.off()
  imp_df
}
REOF

cat > src/feature_analysis/weight_predictors.R << 'REOF'
normalize_scores <- function(x) {
  rng <- max(x) - min(x)
  if (rng == 0) return(rep(0, length(x)))
  (x - min(x)) / rng
}

weight_predictors <- function(cor_scores, anova_df, importance_df, out_dir = "data/results") {
  features   <- importance_df$feature
  cor_norm   <- normalize_scores(cor_scores[features])
  anova_norm <- normalize_scores(setNames(anova_df$f_stat, anova_df$feature)[features])
  imp_norm   <- normalize_scores(setNames(importance_df$importance, importance_df$feature)[features])
  weights <- data.frame(
    feature      = features,
    cor_weight   = cor_norm,
    anova_weight = anova_norm,
    rf_weight    = imp_norm,
    combined     = rowMeans(cbind(cor_norm, anova_norm, imp_norm), na.rm = TRUE)
  )
  weights <- weights[order(-weights$combined), ]
  write.csv(weights, file.path(out_dir, "predictor_weights.csv"), row.names = FALSE)
  weights
}
REOF

cat > src/feature_analysis/run_all_analysis.R << 'REOF'
source("src/feature_analysis/correlation.R")
source("src/feature_analysis/anova_test.R")
source("src/feature_analysis/chi_square_test.R")
source("src/feature_analysis/mutual_info.R")
source("src/feature_analysis/feature_importance.R")
source("src/feature_analysis/weight_predictors.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"
dir.create(OUT_DIR, showWarnings = FALSE)

cor_scores        <- correlate_features(train_clean,     RESPONSE, OUT_DIR)
anova_results     <- run_anova(train_clean,              RESPONSE, OUT_DIR)
chi_results       <- run_chi_square(train_clean,         RESPONSE, OUT_DIR)
mi_scores         <- run_mutual_info(train_clean,        RESPONSE, OUT_DIR)
imp_results       <- run_feature_importance(train_clean, RESPONSE, out_dir = OUT_DIR)
predictor_weights <- weight_predictors(cor_scores, anova_results, imp_results, OUT_DIR)
message("feature analysis complete")
REOF

cat > src/models/knn.R << 'REOF'
library(class)

run_knn <- function(train, test, response, k = 5) {
  train_x <- train[, names(train) != response]
  test_x  <- test[,  names(test)  != response]
  train_y <- train[[response]]
  knn(train = train_x, test = test_x, cl = train_y, k = k)
}
REOF

cat > src/models/linear_regression.R << 'REOF'
run_linear_regression <- function(df, response) {
  lm(as.formula(paste(response, "~ .")), data = df)
}
REOF

cat > src/models/logistic_regression.R << 'REOF'
run_logistic <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  glm(as.formula(paste(response, "~ .")), data = df, family = binomial)
}

predict_logistic <- function(fit, test, threshold = 0.5) {
  probs <- predict(fit, newdata = test, type = "response")
  ifelse(probs >= threshold, 1, 0)
}
REOF

cat > src/models/naive_bayes.R << 'REOF'
library(e1071)

run_naive_bayes <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  naiveBayes(as.formula(paste(response, "~ .")), data = df)
}

predict_naive_bayes <- function(fit, test) {
  predict(fit, newdata = test)
}
REOF

cat > src/models/nonlinearity.R << 'REOF'
library(boot)
library(splines)

best_poly_degree <- function(df, response, predictor, max_degree = 5, k = 10) {
  errors <- rep(0, max_degree)
  for (i in 1:max_degree) {
    fit       <- glm(as.formula(paste(response, "~ poly(", predictor, ",", i, ")")), data = df, family = binomial)
    errors[i] <- cv.glm(df, fit, K = k)$delta[1]
  }
  which.min(errors)
}

run_spline <- function(df, response, predictor, df_spline = 4) {
  glm(as.formula(paste(response, "~ ns(", predictor, ", df =", df_spline, ")")), data = df, family = binomial)
}
REOF

cat > src/models/bootstrap.R << 'REOF'
library(boot)

boot_logistic_coef <- function(df, idx, response) {
  fit <- glm(as.formula(paste(response, "~ .")), data = df[idx, ], family = binomial)
  coef(fit)
}

run_bootstrap <- function(df, response, B = 1000) {
  df[[response]] <- as.numeric(as.factor(df[[response]])) - 1
  boot(df, statistic = function(d, i) boot_logistic_coef(d, i, response), R = B)
}
REOF

cat > src/models/ridge_lasso.R << 'REOF'
library(glmnet)

run_ridge <- function(df, response) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = 0, family = "binomial")
  list(model = cv_fit, lambda = cv_fit$lambda.min)
}

run_lasso <- function(df, response) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = 1, family = "binomial")
  coefs  <- coef(cv_fit, s = "lambda.min")
  kept   <- rownames(coefs)[coefs[, 1] != 0]
  list(model = cv_fit, lambda = cv_fit$lambda.min, kept_features = kept)
}
REOF

cat > src/models/pcr.R << 'REOF'
library(pls)

run_pcr <- function(df, response, out_dir = "data/results") {
  df[[response]] <- as.numeric(df[[response]])
  fit        <- pcr(as.formula(paste(response, "~ .")), data = df, scale = TRUE, validation = "CV")
  best_ncomp <- which.min(fit$validation$PRESS)
  png(file.path(out_dir, "pcr_variance.png"), width = 900, height = 600)
  validationplot(fit, val.type = "MSEP", main = "pcr: MSEP by components")
  dev.off()
  list(model = fit, best_ncomp = best_ncomp)
}
REOF

cat > src/models/run_all_models.R << 'REOF'
source("src/models/knn.R")
source("src/models/linear_regression.R")
source("src/models/logistic_regression.R")
source("src/models/naive_bayes.R")
source("src/models/nonlinearity.R")
source("src/models/bootstrap.R")
source("src/models/ridge_lasso.R")
source("src/models/pcr.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

model_results <- list(
  linear      = run_linear_regression(train_clean, RESPONSE),
  logistic    = run_logistic(train_clean,           RESPONSE),
  naive_bayes = run_naive_bayes(train_clean,        RESPONSE),
  ridge       = run_ridge(train_clean,              RESPONSE),
  lasso       = run_lasso(train_clean,              RESPONSE),
  pcr         = run_pcr(train_clean,                RESPONSE, OUT_DIR),
  bootstrap   = run_bootstrap(train_clean,          RESPONSE)
)
message("all models fitted: ", paste(names(model_results), collapse = ", "))
REOF

cat > tests/feature_analysis/test_correlation.R << 'REOF'
library(testthat)
source("src/feature_analysis/correlation.R")

test_that("correlate_features returns named numeric vector", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- correlate_features(df, "smoking", out_dir = tempdir())
  expect_true(is.numeric(out))
  expect_true(!is.null(names(out)))
})
REOF

cat > tests/feature_analysis/test_anova.R << 'REOF'
library(testthat)
source("src/feature_analysis/anova_test.R")

test_that("run_anova returns dataframe with correct columns", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_anova(df, "smoking", out_dir = tempdir())
  expect_true(all(c("feature", "f_stat", "p_value") %in% names(out)))
})
REOF

cat > tests/models/test_logistic.R << 'REOF'
library(testthat)
source("src/models/logistic_regression.R")

test_that("run_logistic returns a glm object", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  fit <- run_logistic(df, "smoking")
  expect_s3_class(fit, "glm")
})
REOF

cat > tests/models/test_knn.R << 'REOF'
library(testthat)
source("src/models/knn.R")

test_that("run_knn returns predictions of correct length", {
  train <- data.frame(a = rnorm(40), b = rnorm(40), smoking = rbinom(40, 1, 0.5))
  test  <- data.frame(a = rnorm(10), b = rnorm(10), smoking = rbinom(10, 1, 0.5))
  preds <- run_knn(train, test, "smoking", k = 3)
  expect_equal(length(preds), 10)
})
REOF

cat > tests/models/test_ridge_lasso.R << 'REOF'
library(testthat)
source("src/models/ridge_lasso.R")

test_that("run_ridge returns model and lambda", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_ridge(df, "smoking")
  expect_true(!is.null(out$lambda))
})
test_that("run_lasso returns kept_features", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_lasso(df, "smoking")
  expect_true(is.character(out$kept_features))
})
REOF

echo "all files written"
