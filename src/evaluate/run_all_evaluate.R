## evaluate/run_all_evaluate.R
## orchestrator: evaluates all models and combinations on test data
## expects model_results from models/run_all_models.R
## expects train_clean and test_clean from preprocessing pipeline
## saves full leaderboard and roc curves to data/results/

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")
source("src/evaluate/eval_logistic.R")
source("src/evaluate/eval_ridge.R")
source("src/evaluate/eval_lasso.R")
source("src/evaluate/eval_elastic_net.R")
source("src/evaluate/eval_knn.R")
source("src/evaluate/eval_naive_bayes.R")
source("src/evaluate/eval_rf.R")
source("src/evaluate/eval_combinations.R")
source("src/evaluate/compare_models.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

elastic_fit <- fit_elastic_net(train_clean, RESPONSE)

eval_results <- list(
  logistic    = eval_logistic(model_results$logistic,    test_clean, RESPONSE, OUT_DIR),
  ridge       = eval_ridge(model_results$ridge,          test_clean, RESPONSE, OUT_DIR),
  lasso       = eval_lasso(model_results$lasso,          test_clean, RESPONSE, OUT_DIR),
  elastic_net = eval_elastic_net(elastic_fit,            test_clean, RESPONSE, OUT_DIR),
  naive_bayes = eval_naive_bayes(model_results$naive_bayes, test_clean, RESPONSE),
  random_forest = eval_rf(model_results$random_forest,  test_clean, RESPONSE, OUT_DIR),
  knn_5       = eval_knn(train_clean, test_clean,        RESPONSE, k = 5)
)

logistic_probs <- predict(model_results$logistic, newdata = test_clean, type = "response")
ridge_x        <- model.matrix(as.formula(paste(RESPONSE, "~ .")), test_clean)[, -1]
ridge_probs    <- predict(model_results$ridge$model,  newx = ridge_x, s = model_results$ridge$lambda,  type = "response")[, 1]
lasso_probs    <- predict(model_results$lasso$model,  newx = ridge_x, s = model_results$lasso$lambda,  type = "response")[, 1]
elastic_probs  <- predict(elastic_fit$model,           newx = ridge_x, s = elastic_fit$lambda,          type = "response")[, 1]

eval_results$logistic_ridge_avg <- eval_avg_ensemble(
  list(logistic_probs, ridge_probs), test_clean[[RESPONSE]], "logistic_ridge_avg", OUT_DIR)

eval_results$logistic_lasso_avg <- eval_avg_ensemble(
  list(logistic_probs, lasso_probs), test_clean[[RESPONSE]], "logistic_lasso_avg", OUT_DIR)

eval_results$logistic_elastic_avg <- eval_avg_ensemble(
  list(logistic_probs, elastic_probs), test_clean[[RESPONSE]], "logistic_elastic_avg", OUT_DIR)

eval_results$top3_avg <- eval_avg_ensemble(
  list(logistic_probs, ridge_probs, elastic_probs), test_clean[[RESPONSE]], "top3_avg", OUT_DIR)

leaderboard <- compare_models(eval_results, OUT_DIR)
message("evaluation complete — leaderboard saved to data/results/model_comparison.csv")
