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
