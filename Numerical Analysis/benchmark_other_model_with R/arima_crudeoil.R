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
crudeoil <- read_csv("./data/crudeoilproduction.csv",col_names = FALSE, show_col_types = FALSE)
crudeoil <- as.matrix(crudeoil)
# View(crudeoil) view data


# model setting
train_data_length = 180
train_data_index = c(1:train_data_length)
val_data_length = 108
train_val_data_index = c(1:(train_data_length+val_data_length))
test_data_length = 108
train_test_data_index = c((nrow(crudeoil)-test_data_length-train_data_length+1):nrow(crudeoil))
val_step = 12
test_step = 12


crudeoiltrain <- vector()
crudeoilfit <- vector()
crudeoiltest <- vector()
crudeoilpre <- vector()


# train and val data
crudeoil_train_val <- crudeoil[train_val_data_index]
crudeoil_train_val_ts <- ts(data=crudeoil_train_val, frequency = 12, start = 1)
# train and val data
crudeoil_train_test <- crudeoil[train_test_data_index]
crudeoil_train_test_ts <- ts(data=crudeoil_train_test, frequency = 12, start = test_data_length+1)
# obtain SARIMA order
crudeoil_arima <- auto.arima(crudeoil_train_val_ts)
arima_order <- arimaorder(crudeoil_arima)
# 
k <- 1
crudeoil_train_all <- vector()
crudeoil_fit_all <- vector()
crudeoil_test_all <- vector()
crudeoil_pre_all <- vector()
while ((k+train_data_length+test_step-1) <= NROW(train_test_data_index)) {
  # train data
  crudeoil_train <- crudeoil_train_test[k:(k+train_data_length-1)]
  crudeoil_train_all <- c(crudeoil_train_all,crudeoil_train)
  # test data
  crudeoil_test <- crudeoil_train_test[(k+train_data_length):(k+train_data_length+test_step-1)]
  crudeoil_test_all <- c(crudeoil_test_all,crudeoil_test)
  # time series
  crudeoil_train_ts <-ts(data=crudeoil_train, frequency = 12, start = 1)
  # establish SARIMA model
  crudeoil_train_arima <- Arima(crudeoil_train_ts,order = arima_order[1:3],seasonal = arima_order[4:6],method = c("CSS"))
  crudeoil_test_fore <- forecast(crudeoil_train_arima, h = test_step)
  # train value
  crudeoil_train_fit <-as.vector(crudeoil_train_arima$fitted)
  crudeoil_fit_all <- c(crudeoil_fit_all,crudeoil_train_fit)
  # testing value
  crudeoil_test_pre <- as.vector(crudeoil_test_fore$mean)
  crudeoil_pre_all <- c(crudeoil_pre_all,crudeoil_test_pre)
  k <- k+test_step
}

# plot
windows()
plot(crudeoil_train_all)
lines(crudeoil_fit_all)
windows()
plot(crudeoil_test_all)
lines(crudeoil_pre_all)

# compute error
# training error
crudeoil_train_AE <- abs(crudeoil_fit_all-crudeoil_train_all)
crudeoil_train_MAE <- mean(crudeoil_train_AE)
# testing error
crudeoil_test_AE <- abs(crudeoil_pre_all-crudeoil_test_all)
crudeoil_test_MAE <- mean(crudeoil_test_AE)


# data export
write.csv(crudeoil_fit_all,"./result/crudeoil_fit_ARIMA_.csv")
write.csv(crudeoil_pre_all,"./result/crudeoil_pre_ARIMA.csv")


# return to current_path
setwd(current_path)
