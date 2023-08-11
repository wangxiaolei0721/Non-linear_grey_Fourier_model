# clear work space and screen
rm(list=ls()) # clear data and value
shell("cls") # clear screen
gc() # clear memory
graphics.off() # clear graphics


# load package
library(forecast)
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
electricity_train_val_ts <- ts(data=electricity_train_val, frequency = 4, start = 1)
# train and val data
electricity_train_test <- electricityquarter[train_test_data_index]
electricity_train_test_ts <- ts(data=electricity_train_test, frequency = 4, start = test_data_length+1)
# obtain Holt-Winter order
electricity_ets <- ets(electricity_train_val_ts)
ets_order <- electricity_ets$components
model0 <- paste(ets_order[1:3],collapse="")
damped0 <- ets_order[4]
# 
k <- 1
electricity_train_all <- vector()
electricity_fit_all <- vector()
electricity_test_all <- vector()
electricity_pre_all <- vector()
while ((k+train_data_length+test_step-1) <= NROW(train_test_data_index)) {
  # train data
  electricity_train <- electricity_train_test[k:(k+train_data_length-1)]
  electricity_train_all <- c(electricity_train_all,electricity_train)
  # test data
  electricity_test <- electricity_train_test[(k+train_data_length):(k+train_data_length+test_step-1)]
  electricity_test_all <- c(electricity_test_all,electricity_test)
  # time series
  electricity_train_ts <-ts(data=electricity_train, frequency = 4, start = 1)
  # establish Sets model
  electricity_train_ets <- ets(electricity_train_ts, model = model0, as.logical(damped0))
  electricity_test_fore <- forecast(electricity_train_ets, h = test_step)
  # train value
  electricity_train_fit <-as.vector(electricity_train_ets$fitted)
  electricity_fit_all <- c(electricity_fit_all,electricity_train_fit)
  # testing value
  electricity_test_pre <- as.vector(electricity_test_fore$mean)
  electricity_pre_all <- c(electricity_pre_all,electricity_test_pre)
  k <- k+test_step
}

# plot
windows()
plot(electricity_train_all)
lines(electricity_fit_all)
windows()
plot(electricity_test_all)
lines(electricity_pre_all)
# compute error
# training error
electricity_train_AE <- abs(electricity_fit_all-electricity_train_all)
electricity_train_MAE <- mean(electricity_train_AE)
# testing error
electricity_test_AE <- abs(electricity_pre_all-electricity_test_all)
electricity_test_MAE <- mean(electricity_test_AE)


# data export
write.csv(electricity_fit_all,"./result/electricity_fit_ARIMA_.csv")
write.csv(electricity_pre_all,"./result/electricity_pre_ARIMA.csv")


# return to current_path
setwd(current_path)
