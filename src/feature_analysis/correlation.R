## feature_analysis/correlation.R
## given preprocessed train data and response name
## return sorted correlation of each numeric predictor with response
## saves plot to data/results/correlation.png

library(dplyr)

#' given a numeric vector and a binary response vector
#' return pearson correlation coefficient
cor_with_response <- function(x, y) {
  cor(x, as.numeric(y), use = "complete.obs", method = "pearson")
}

#' given a dataframe and response name
#' return named numeric vector of correlations sorted by absolute value
#' saves bar plot of correlations to data/results/
correlate_features <- function(df, response, out_dir = "data/results") {
  num_cols <- names(df)[sapply(df, is.numeric) & names(df) != response]
  cors     <- sapply(num_cols, function(col) cor_with_response(df[[col]], df[[response]]))
  sorted   <- sort(abs(cors), decreasing = TRUE)

  png(file.path(out_dir, "correlation.png"), width = 900, height = 600)
  barplot(sorted, las = 2, main = "absolute correlation with smoking",
          ylab = "abs(correlation)", col = "steelblue")
  dev.off()

  message("saved: ", file.path(out_dir, "correlation.png"))
  sorted
}
