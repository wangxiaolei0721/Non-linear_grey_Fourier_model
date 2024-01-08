clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\roadhour.mat;
load .\data\order.mat;
load .\data\parameter.mat;
% data set setting
train_data_length = 30*24;
% val_data_length = 16*24;
% from August 1st to September 15th
% train_val_data_index = [1:train_data_length+val_data_length]';
test_data_length = 15*24;
% from September 15 to 30
train_test_data_index = [(length(roadhour)-test_data_length-train_data_length)+1:length(roadhour)]';
% val_step = 24;
test_step = 24;
% model setting
omega=pi/12; % angular frequency
% figure setting
fig=figure('unit','centimeters','position',[0,0,30,20],'PaperPosition',[0, 0, 30,20],'PaperSize',[30,20]);
tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact'); % new subfigure
% begin loop
road4train=[];
road4fit=[];
road4test=[];
road4pre=[];
for l=1:4
    orderi=order(l,1);
    gammai=gammaopt(l,1);
    sigmai=sigmaopt(l,1);
    road_train_test=roadhour(train_test_data_index ,roadsample(l));
    datalength=length(road_train_test);
    k=1; % Mark the first position of the data to be calculated
    road_train_all=[];
    road_fit_all=[];
    road_test_all=[];
    road_pre_all=[];
    while (k+train_data_length+test_step-1)<=datalength
        % train data
        road_train=road_train_test(k:k+train_data_length-1);
        road_train_all=[road_train_all;road_train];
        % test data
        road_test=road_train_test(k+train_data_length:k+train_data_length+test_step-1);
        road_test_all=[road_test_all;road_test];
        % call model code
        road_fit_pre = NGFM(road_train,omega,orderi,gammai,sigmai,test_step);
        % fitting data
        road_fit=road_fit_pre(1:train_data_length);
        % all fitting data
        road_fit_all=[road_fit_all;road_fit];
        % predictive data
        road_pre=road_fit_pre(train_data_length+1:end);
        % all predictive data
        road_pre_all=[road_pre_all;road_pre];
        % location update
        k=k+test_step;
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