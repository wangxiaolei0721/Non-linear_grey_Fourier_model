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
% figure setting
fig=figure('unit','centimeters','position',[5,5,40,20],'PaperPosition',[5, 5, 40,20],'PaperSize',[40,20]);
tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact'); % new subfigure
% begin loop
road4train=[];
road4fit=[];
road4test=[];
road4pre=[];
for l=1:4
    orderi=order(l,1);
    gammai=gamma(l,1);
    sigmai=sigma(l,1);
    road_online=roadhour(online_data,roadsample(l));
    datalength=length(road_online);
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
        road_fit_pre = NGFM(road_train,omega,orderi,gammai,sigmai,test);
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
    % plot
    nexttile % next subfigure
    plot(road_test_all);
    hold on
    plot(road_pre_all)
    % store data
    road4train(:,l)=road_train_all;
    road4fit(:,l)=road_fit_all;
    road4test(:,l)=road_test_all;
    road4pre(:,l)=road_pre_all;
end
mae_fit=mean(abs(road4fit-road4train),1);
mae_pre=mean(abs(road4pre-road4test),1);
% savefig(gcf,'Forecast evaluation.fig');
toc