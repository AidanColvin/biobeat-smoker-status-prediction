## dimensionality_reduction/apply_pca.R
## given a numeric dataframe and number of components
## return list with rotated data and fitted pca model

#' given a numeric dataframe and number of components to retain
#' return list with rotated data frame and pca model object
apply_pca <- function(df, n_components = 2) {
  model   <- prcomp(df, center = TRUE, scale. = TRUE)
  rotated <- as.data.frame(model$x[, 1:n_components])
  list(data = rotated, model = model)
}