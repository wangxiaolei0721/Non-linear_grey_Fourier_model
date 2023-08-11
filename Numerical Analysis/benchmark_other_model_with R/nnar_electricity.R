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
# establish neural net
set.seed(1)
electricity_nnetar <- nnetar(electricity_train_val_ts,size = 3)


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
  # establish nnetar model
  electricity_train_nnetar <- nnetar(electricity_train_ts,size=3,p=electricity_nnetar$p,P=electricity_nnetar$P,lambda=electricity_nnetar$lambda)
  electricity_test_fore <- forecast(electricity_train_nnetar, h = test_step)
  # train value
  electricity_train_fit <-as.vector(electricity_train_nnetar$fitted)
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

write.csv(electricity_fit_all,"./result/electricity_fit_nnetar_.csv")
write.csv(electricity_pre_all,"./result/electricity_pre_nnetar.csv")


# return to current_path
setwd(current_path)

