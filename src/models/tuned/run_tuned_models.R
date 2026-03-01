## models/tuned/run_tuned_models.R
## orchestrator: fits all tuned models on train_clean with id removed
## expects train_clean from load_data.R
## passes tuned_results to evaluate

source("src/models/tuned/remove_id.R")
source("src/models/tuned/tune_rf.R")
source("src/models/tuned/xgboost_model.R")
source("src/models/tuned/elastic_net_tuned.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

train_tuned <- remove_id(train_clean)
test_tuned  <- remove_id(test_clean)

message("fitting tuned random forest (10-fold cv mtry search)...")
rf_tuned <- tune_rf(train_tuned, RESPONSE, ntree = 500, k = 10)

message("fitting tuned elastic net (alpha grid search)...")
elastic_tuned <- tune_elastic_net(train_tuned, RESPONSE, k = 10)

message("fitting xgboost (10-fold cv nrounds)...")
xgb_fit <- tune_xgboost(train_tuned, RESPONSE, max_rounds = 300, k = 10)

tuned_results <- list(
  rf_tuned      = rf_tuned,
  elastic_tuned = elastic_tuned,
  xgb           = xgb_fit
)

message("tuned models ready: ", paste(names(tuned_results), collapse = ", "))
