## models/knn.R
## given train and test data, response name, and k
## return knn predictions on test set

library(class)

#' given train data, test data, response name, and number of neighbors
#' return factor vector of knn predictions for test set
run_knn <- function(train, test, response, k = 5) {
  train_x <- train[, names(train) != response]
  test_x  <- test[,  names(test)  != response]
  train_y <- train[[response]]
  knn(train = train_x, test = test_x, cl = train_y, k = k)
}
