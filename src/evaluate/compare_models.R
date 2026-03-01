## evaluate/compare_models.R
## given a list of eval result objects
## return sorted comparison table of all models by auc
## saves leaderboard to data/results/model_comparison.csv

#' given a list of eval result lists each with model name and metrics
#' return dataframe sorted by auc descending
compare_models <- function(eval_results, out_dir = "data/results") {
  rows <- lapply(eval_results, function(r) {
    data.frame(
      model     = r$model,
      accuracy  = round(r$metrics$accuracy,  4),
      precision = round(r$metrics$precision, 4),
      recall    = round(r$metrics$recall,    4),
      f1        = round(r$metrics$f1,        4),
      auc       = round(ifelse(is.null(r$auc), NA, r$auc), 4)
    )
  })
  tbl <- do.call(rbind, rows)
  tbl <- tbl[order(-tbl$auc, na.last = TRUE), ]
  write.csv(tbl, file.path(out_dir, "model_comparison.csv"), row.names = FALSE)
  message("\n── model leaderboard ─────────────────")
  print(tbl)
  message("─────────────────────────────────────")
  tbl
}
