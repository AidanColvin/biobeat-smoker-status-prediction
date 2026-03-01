## train/train_lda.R
## given train data and response name
## return fitted lda model on full training set

library(MASS) # lda

#' given a dataframe and response name
#' return fitted lda model
train_lda <- function(df, response) {
  lda(as.formula(paste(response, "~ .")), data = df)
}