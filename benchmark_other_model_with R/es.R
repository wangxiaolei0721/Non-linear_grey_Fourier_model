# clear work space and screen
rm(list=ls()) # clear data and value
shell("cls") # clear screen
gc() # clear memory


# load package
library(forecast) # packages for Holt-Winter
library(readr)
library(ggplot2)


# set script path
current_path<-getwd()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# read data from .csv document
Road <- read_csv("./trafficdata.csv",col_names = FALSE, show_col_types = FALSE)
names(Road) <- c("Road207","Road117","Road194","Road44")
# View(CSJ_PM25) view data


# offline data and online data
offline_data <- c(1:1104)
online_data <- c(1104:nrow(Road))


road4train <- vector()
road4fit <- vector()
road4test <-vector()
road4pre <- vector()


for (i in c(1:4)) {
  # offline data
  road_offline <- as.matrix(Road[offline_data,i])
  road_offline_ts <- ts(data=road_offline, frequency = 24, start = 1)
  # online data
  road_online <- as.matrix(Road[online_data,i])
  road_online_ts <- ts(data=road_online, frequency = 24, start = 1105)
  # obtain Holt-Winter order
  road_ets <- ets(road_offline_ts)
  ets_order <- road_ets$components
  model0 <- paste(ets_order[1:3],collapse="")
  damped0 <- ets_order[4]
  # 
  k <- 1
  train=7*24;
  test=24
  road_train_all <- vector()
  road_fit_all <- vector()
  road_test_all <- vector()
  road_pre_all <- vector()
  while ((k+train+test-1) <= NROW(online_data)) {
    # train data
    road_train <- road_online[k:(k+train-1),1]
    road_train_all <- c(road_train_all,road_train)
    # test data
    road_test <- road_online[(k+train):(k+train+test-1),1]
    road_test_all <- c(road_test_all,road_test)
    # time series
    road_train_ts <-ts(data=road_train, frequency = 24, start = 1)
    # establish Sets model
    road_train_ets <- ets(road_train_ts, model = model0, as.logical(damped0))
    road_test_fore <- forecast(road_train_ets, h = test)
    # train value
    road_train_fit <-as.vector(road_train_ets$fitted)
    road_fit_all <- c(road_fit_all,road_train_fit)
    # testing value
    road_test_pre <-as.vector(road_test_fore$mean)
    road_pre_all <- c(road_pre_all,road_test_pre)
    k <- k+test
  }
  road4train <- cbind(road4train,road_train_all)
  road4fit <- cbind(road4fit,road_fit_all)
  road4test <- cbind(road4test,road_test_all)
  road4pre <- cbind(road4pre,road_pre_all)
}
# compute error
# training error
road4_train_AE <- abs(road4fit-road4train)
road_train_MAE <- apply(road4_train_AE,2,mean)
# testing error
road4_test_AE <- abs(road4pre-road4test)
road_test_MAE <- apply(road4_test_AE,2,mean)


# data export

# write.csv(road4fit,"./result/road4fit_ets.csv")
write.csv(road4fit,"../benchmark_statistical_model_data/road4fit_ets.csv")

# write.csv(road4pre,"./result/road4pre_ets.csv")
write.csv(road4pre,"../benchmark_statistical_model_data/road4pre_ets.csv")


# return to current_path
setwd(current_path)
