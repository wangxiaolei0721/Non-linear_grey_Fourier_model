# clear work space and screen
rm(list=ls()) # clear data and value
shell("cls") # clear screen
gc() # clear memory
graphics.off() # clear graphics


# load package
library(keras)
library(readr)
library(ggplot2)


# set script path
current_path<-getwd()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# read data from .csv document
electricityquarter <- read_csv("./data/electricityquarter.csv",col_names = FALSE, show_col_types = FALSE)
electricityquarter <- as.matrix(electricityquarter)
# View(electricityquarter) view data


# model setting
train_data_length = 24
train_data_index = c(1:train_data_length)
val_data_length = 16
train_val_data_index = c(1:(train_data_length+val_data_length))
test_data_length = 12
train_test_data_index = c((nrow(electricityquarter)-test_data_length-train_data_length+1):nrow(electricityquarter))
val_step = 4
test_step = 4



electricitytrain <- vector()
electricityfit <- vector()
electricitytest <- vector()
electricitypre <- vector()


# train and val data
electricity_train_val <- electricityquarter[train_val_data_index]

# train and test data
electricity_train_test <- electricityquarter[train_test_data_index]


# model parameter
lookback <- 8  # backtracking time step
delay <- 1 # prediction step
batch_size <- 4 # batch size


# data generator with batch size
# min_index represents the first data index which equals lookback at least
# max_index indicates the last data index
# for traning data it equals train length - delay
# j indicates the last location in the input data
generator <- function(data, lookback, delay, min_index, max_index,
                      shuffle = FALSE, batch_size = 4) {
  if (is.null(max_index)) max_index <- length(data)-delay
  i <- min_index # begin from min_index - 1
  # print(i)
  function() {
    if (shuffle) {
      rows <- sample(c(min_index:max_index), size = batch_size)
    } else {
      if (i + batch_size - 1 > max_index)
        i <<- min_index
      rows <- c(i:min(i+batch_size-1, max_index))
      i <<- i + length(rows)
    }
    # print(rows)
    samples <- array(0, dim = c(length(rows),
                                lookback))
    targets <- array(0, dim = c(length(rows)))
    for (j in 1:length(rows)) {
      indices <- seq(rows[[j]] - lookback+1, rows[[j]],
                     length.out = dim(samples)[[2]])
      samples[j,] <- data[indices]
      targets[[j]] <- data[rows[[j]] + delay]
    }
    data_list <- list(samples, targets)
    return(data_list)
  }
}



electricity_train_gen <- generator(
  electricity_train_val,
  lookback = lookback,
  delay = delay,
  # the minimal index is the lookback
  min_index = lookback,
  # the maximal index is the train - delay
  max_index = train_data_length-delay,
  # shuffle = TRUE,
  batch_size = batch_size
)



electricity_val_gen = generator(
  electricity_train_val,
  lookback = lookback,
  delay = delay,
  min_index = train_data_length,
  max_index = train_data_length+val_data_length-delay,
  batch_size = batch_size
)
val_steps <- val_data_length / batch_size



# fully connected neural network
set.seed(0)
electricity_model <- keras_model_sequential() %>%
  # units = 4 8 12
  layer_dense(units = 12, activation = "relu",input_shape = c(lookback)) %>%
  # layer_lstm(units = 8, input_shape=list(NULL, 1)) %>%
  layer_dense(units = 1)
electricity_model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mape"
)


history <- electricity_model %>% fit(
  electricity_train_gen,
  steps_per_epoch = 20,
  epochs = 20,
  validation_data = electricity_val_gen,
  validation_steps = val_steps
)

plot(history)


# Here, we iterate with a prediction step size of 4 to generate the predicted values of the test data
electricity_result <- rep(NA, nrow(electricityquarter))
# data index that requires a loop: test_data_length+1 to nrow(electricityquarter) with test_step
begin <- train_data_length+val_data_length+1
test_data_index <- seq(begin,nrow(electricityquarter),test_step)
for (test_index in test_data_index){
  # initial size is lookback 
 test_four_data <- electricityquarter[(test_index-lookback):(test_index-1)]
 for (step in c(1:test_step)){
   # test_four_data as model input
   test_one_step <-t(test_four_data[step:(step+lookback-1)])
   test_four_data[lookback+step] <- electricity_model %>% predict(test_one_step)
 }
 electricity_result[test_index:(test_index+test_step-1)] <- test_four_data[(lookback+1):(lookback+test_step)]
}

plot(as.matrix(electricityquarter))
lines(electricity_result)


electricity_test_all <- electricityquarter[begin:nrow(electricityquarter)]
electricity_pre_all <- electricity_result[begin:nrow(electricityquarter)]

# plot
windows()
plot(electricity_test_all)
lines(electricity_pre_all)


# testing error
electricity_test_AE <- abs(electricity_pre_all-electricity_test_all)
electricity_test_MAE <- mean(electricity_test_AE)


write.csv(electricity_pre_all,"./result/electricity_pre_dnn.csv")

# return to current_path
setwd(current_path)

