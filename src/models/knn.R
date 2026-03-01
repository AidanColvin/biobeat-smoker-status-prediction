library(class)

run_knn <- function(train, test, response, k = 5) {
  train_x <- train[, names(train) != response]
  test_x  <- test[,  names(test)  != response]
  train_y <- train[[response]]
  knn(train = train_x, test = test_x, cl = train_y, k = k)
}
