## feature_engineering/one_hot_encode.R
## given a dataframe and factor column names
## return dataframe with one-hot encoded columns replacing originals

library(recipes)

#' given a dataframe and a vector of factor column names
#' return dataframe with one-hot encoded columns
one_hot_encode <- function(df, cols) {
  rec <- recipe(~ ., data = df) %>%
    step_dummy(all_of(cols), one_hot = TRUE) %>%
    prep()
  bake(rec, new_data = df)
}