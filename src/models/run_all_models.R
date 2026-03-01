## models/run_all_models.R
## orchestrator: fits all models on train_clean
## expects train_clean from preprocessing and predictor_weights from feature_analysis
## saves all model objects to model_results list

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
  linear    = run_linear_regression(train_clean, RESPONSE),
  logistic  = run_logistic(train_clean,          RESPONSE),
  naive_bayes = run_naive_bayes(train_clean,     RESPONSE),
  ridge     = run_ridge(train_clean,             RESPONSE),
  lasso     = run_lasso(train_clean,             RESPONSE),
  pcr       = run_pcr(train_clean,               RESPONSE, OUT_DIR),
  bootstrap = run_bootstrap(train_clean,         RESPONSE)
)

message("all models fitted: ", paste(names(model_results), collapse = ", "))
