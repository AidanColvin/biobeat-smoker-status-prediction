## evaluate/run_tuned_evaluate.R
## runs evaluation on all tuned models
## expects tuned_results from models/tuned/run_tuned_models.R
## saves updated leaderboard to data/results/tuned_comparison.csv

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")
source("src/evaluate/compare_models.R")
source("src/evaluate/eval_tuned.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

test_tuned <- remove_id(test_clean)

tuned_eval <- list(
  rf_tuned      = eval_tuned_rf(tuned_results$rf_tuned,      test_tuned, RESPONSE, OUT_DIR),
  xgboost       = eval_xgboost(tuned_results$xgb,            test_tuned, RESPONSE, OUT_DIR),
  elastic_tuned = eval_tuned_elastic(tuned_results$elastic_tuned, test_tuned, RESPONSE, OUT_DIR)
)

leaderboard <- compare_models(tuned_eval, OUT_DIR)
write.csv(leaderboard, file.path(OUT_DIR, "tuned_comparison.csv"), row.names = FALSE)
message("tuned leaderboard saved to data/results/tuned_comparison.csv")
