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



# read data from .csv document
Road <- read_csv("./data/trafficdata.csv",col_names = FALSE, show_col_types = FALSE)
Road <- as.matrix(Road)


# model setting
train_data_length = 30*24
train_data_index = c(1:train_data_length)
val_data_length = 16*24
train_val_data_index = c(1:(train_data_length+val_data_length))
test_data_length = 15*24
train_test_data_index = c((nrow(Road)-test_data_length-train_data_length+1):nrow(Road))
val_step = 24
test_step = 24



road4_test <-vector()
road4_pre <- vector()


# model parameter
lookback <- 7*24  # backtracking time step
delay <- 1 # prediction step
batch_size <- 24 # batch size

for (i in c(1:4)) {
  # train and val data
  Road_train_val <- Road[train_val_data_index,i]
  # train and val data
  Road_train_test <- Road[train_test_data_index,i]
  
  
  
  Road_train_gen <- generator(
    Road_train_val,
    lookback = lookback,
    delay = delay,
    # the minimal index is the lookback
    min_index = lookback,
    # the maximal index is the train - delay
    max_index = train_data_length-delay,
    # shuffle = TRUE,
    batch_size = batch_size
  )
  
  
  
  Road_val_gen = generator(
    Road_train_val,
    lookback = lookback,
    delay = delay,
    min_index = train_data_length,
    max_index = train_data_length+val_data_length-delay,
    batch_size = batch_size
  )
  val_steps <- val_data_length / batch_size
  
  
  
  # fully connected neural network
  set.seed(0)
  Road_model <- keras_model_sequential() %>%
    # units = 4 8 12
    layer_gru(units = 24, input_shape=list(NULL, 1)) %>%
    layer_dense(units = 12, activation = "relu") %>%
    layer_dense(units = 1)
  Road_model %>% compile(
    optimizer = optimizer_rmsprop(),
    loss = "mape"
  )
  
  
  history <- Road_model %>% fit(
    Road_train_gen,
    steps_per_epoch = 10,
    epochs = 100,
    validation_data = Road_val_gen,
    validation_steps = val_steps
  )
  
  plot(history)
  
  
  
  # Here, we iterate with a prediction step size of 4 to generate the predicted values of the test data
  Road_result <- rep(NA, nrow(Road))
  # data index that requires a loop: test_data_length+1 to nrow(Road) with test_step
  begin <- train_data_length+val_data_length+1
  test_data_index <- seq(begin,nrow(Road),test_step)
  for (test_index in test_data_index){
    # initial size is lookback 
    test_four_data <- Road[(test_index-lookback):(test_index-1),i]
    for (step in c(1:test_step)){
      # test_four_data as model input
      test_one_step <-t(test_four_data[step:(step+lookback-1)])
      test_four_data[lookback+step] <- Road_model %>% predict(test_one_step)
    }
    Road_result[test_index:(test_index+test_step-1)] <- test_four_data[(lookback+1):(lookback+test_step)]
  }
  Road_test_all <- Road[begin:nrow(Road),i]
  Road_pre_all <- Road_result[begin:nrow(Road)]
  road4_test <- cbind(road4_test,Road_test_all)
  road4_pre <- cbind(road4_pre,Road_pre_all)
}

# testing error
road4_test_AE <- abs(road4_pre-road4_test)
road4_test_MAE <- apply(road4_test_AE,2,mean)


write.csv(road4_pre,"./result/road4_pre_gru.csv")


# return to current_path
setwd(current_path)

