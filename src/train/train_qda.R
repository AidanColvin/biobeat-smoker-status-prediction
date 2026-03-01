## train/train_qda.R
## given train data and response name
## return fitted qda model on full training set

library(MASS) # qda

#' given a dataframe and response name
#' return fitted qda model
train_qda <- function(df, response) {
  qda(as.formula(paste(response, "~ .")), data = df)
}