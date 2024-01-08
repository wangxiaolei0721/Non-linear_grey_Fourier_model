clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Non-linear grey Fourier model','..\Urban Traffic Speed Dataset','..\Hyperparametric optimization')
% load data
load roadhour.mat;
load order.mat;
load parameter.mat;
% model setting
omega=pi/12; % angular frequency
online_data=[745:length(roadhour)]';
train=7*24;
test=24;
l=2;
orderi=order(l,1);
gammai=1;
sigmai=sigma(l,1);
road_online=roadhour(online_data,roadsample(l));
datalength=168+24;
k=1; % Mark the first position of the data to be calculated
road_train_all=[];
road_fit_all=[];
road_test_all=[];
road_pre_all=[];
while (k+train+test-1)<=datalength
    % train data
    road_train=road_online(k:k+train-1);
    road_train_all=[road_train_all;road_train];
    % test data
    road_test=road_online(k+train:k+train+test-1);
    road_test_all=[road_test_all;road_test];
    % call model code
    road_fit_pre = NGFM(road_train,omega,orderi,gammai,sigmai,test); % DGFM( road_train,omega,orderi,test); % 
    % fitting data
    road_fit=road_fit_pre(1:train);
    % all fitting data
    road_fit_all=[road_fit_all;road_fit];
    % predictive data
    road_pre=road_fit_pre(train+1:end);
    % all predictive data
    road_pre_all=[road_pre_all;road_pre];
    % location update
    k=k+test;
end
plot(road_train_all)
hold on
plot(road_fit_all)
% xlim([-5,175])
figure
% plot
plot(road_test_all);
hold on
plot(road_pre_all)
mae_fit=mean(abs(road_fit_all-road_train_all),1);
mae_pre=mean(abs(road_pre_all-road_test_all),1);
% savefig(gcf,'Forecast evaluation.fig');
toc