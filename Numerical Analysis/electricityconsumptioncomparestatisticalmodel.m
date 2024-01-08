clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Modelcode')
%% NGFM model
% load data
load .\data\electricityconsumption.mat;
load .\data\electricityorder.mat;
load .\data\electricityhyperparameter.mat;
% model setting
omega=pi/2; % angular frequency
train_data_length = 24;
train_data_index = [1:train_data_length]';
val_data_length = 16;
train_val_data_index= [1:train_data_length+val_data_length]';
test_data_length = 12;
train_test_data_index = [(length(electricityquarter)-test_data_length-train_data_length)+1:length(electricityquarter)]';
val_step = 4;
test_step = 4;
electricity_train_test=electricityquarter(train_test_data_index);
datalength=length(electricity_train_test);
datequarter_train_test = datequarter(train_test_data_index);
k=1;
% disp(k)
electricity_train_all=[];
electricity_fit_all=[];
electricity_test_all=[];
electricity_pre_all=[];
% NGFM model
electricity_fit_NGFM=[];
electricity_pre_NGFM=[];
datequarter_train_all=[];
datequarter_test_all=[];
while (k+train_data_length+test_step-1)<=datalength
    % train data
    electricity_train=electricity_train_test(k:k+train_data_length-1);
    electricity_train_all=[electricity_train_all;electricity_train];
    datequarter_train = datequarter_train_test(k:k+train_data_length-1);
    datequarter_train_all=[datequarter_train_all; datequarter_train];
    % test data
    electricity_test=electricity_train_test(k+train_data_length:k+train_data_length+test_step-1);
    electricity_test_all=[electricity_test_all;electricity_test];
    datequarter_test = datequarter_train_test(k+train_data_length:k+train_data_length+test_step-1);
    datequarter_test_all=[datequarter_test_all; datequarter_test];
    % call model code
    electricity_fit_pre = NGFM(electricity_train,omega,order,gammaopt,sigmaopt,test_step);
    % fitting data
    electricity_fit=electricity_fit_pre(1:train_data_length);
    % all fitting data
    electricity_fit_NGFM=[electricity_fit_NGFM;electricity_fit];
    % predictive data
    electricity_pre=electricity_fit_pre(train_data_length+1:end);
    % all predictive data
    electricity_pre_NGFM=[electricity_pre_NGFM;electricity_pre];
    % location update
    k=k+test_step;
    %  disp(k)
end
% read data from R output
% ARIMA
electricity_fit_ARIMA = readtable("benchmark_statistical_model_data\electricity_fit_ARIMA.csv",'VariableNamingRule','preserve');
electricity_fit_ARIMA.Var1=[];
electricity_fit_ARIMA = table2array(electricity_fit_ARIMA);
electricity_fit_all(:,1)=electricity_fit_ARIMA;
electricity_pre_ARIMA = readtable("benchmark_statistical_model_data\electricity_pre_ARIMA.csv",'VariableNamingRule','preserve');
electricity_pre_ARIMA.Var1=[];
electricity_pre_ARIMA = table2array(electricity_pre_ARIMA);
electricity_pre_all(:,1)=electricity_pre_ARIMA;
% ets
electricity_fit_ets = readtable("benchmark_statistical_model_data\electricity_fit_ets.csv",'VariableNamingRule','preserve');
electricity_fit_ets.Var1=[];
electricity_fit_ets = table2array(electricity_fit_ets);
electricity_fit_all(:,2)=electricity_fit_ets;
electricity_pre_ets = readtable("benchmark_statistical_model_data\electricity_pre_ets.csv",'VariableNamingRule','preserve');
electricity_pre_ets.Var1=[];
electricity_pre_ets = table2array(electricity_pre_ets);
electricity_pre_all(:,2)=electricity_pre_ets;
% nnetar
electricity_fit_nnetar = readtable("benchmark_statistical_model_data\electricity_fit_nnetar.csv",'VariableNamingRule','preserve');
electricity_fit_nnetar.Var1=[];
electricity_fit_nnetar = table2array(electricity_fit_nnetar);
electricity_fit_all(:,3)=electricity_fit_nnetar;
electricity_pre_nnetar = readtable("benchmark_statistical_model_data\electricity_pre_nnetar.csv",'VariableNamingRule','preserve');
electricity_pre_nnetar.Var1=[];
electricity_pre_nnetar = table2array(electricity_pre_nnetar);
electricity_pre_all(:,3)=electricity_pre_nnetar;
% deep neural net
electricity_fit_dnn = NaN(size(electricity_fit_nnetar));
electricity_fit_all(:,4)=electricity_fit_dnn;
electricity_pre_dnn = readtable("benchmark_statistical_model_data\electricity_pre_dnn.csv",'VariableNamingRule','preserve');
electricity_pre_dnn.Var1=[];
electricity_pre_dnn = table2array(electricity_pre_dnn);
electricity_pre_all(:,4)=electricity_pre_dnn;
electricity_fit_all(:,5)=electricity_fit_NGFM;
electricity_pre_all(:,5)=electricity_pre_NGFM;
% compute mean absolute error
mae_fit=mean(abs(electricity_fit_all-repmat(electricity_train_all,1,5)),1,'omitnan');
mae_pre=mean(abs(electricity_pre_all-repmat(electricity_test_all,1,5)),1,'omitnan');
mae2latex(1,:)=mae_fit;
mae2latex(2,:)=mae_pre;
% figure setting
fig=figure('unit','centimeters','position',[2,2,15,15],'PaperPosition',[2, 2, 15,15],'PaperSize',[15,15]);
tit={['(a) First roll '],['(b) Second roll '],['(c) Third roll '],['(d) Fourth roll '] };
tit0=1;
col_matrix = [0,0,0;
    87, 103, 250;
    160, 98, 205;
    60, 191, 255;
    240, 163, 70;
    239, 55, 81]/255;
colororder(col_matrix);
len=["Actual data","SARIMA","ES","NNAR","DNN","NGFM(1,1,1)"];
tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
for i=1:3
    nexttile;
    datequarter_roll=[datequarter_train_all((i-1)*train_data_length+1:i*train_data_length);datequarter_test_all((i-1)*test_step+1:i*test_step)];
    electricity_roll=[electricity_train_all((i-1)*train_data_length+1:i*train_data_length);electricity_test_all((i-1)*test_step+1:i*test_step)];
    electricity_roll_fit=[electricity_fit_all((i-1)*train_data_length+1:i*train_data_length,:);electricity_pre_all((i-1)*test_step+1:i*test_step,:)];
    plot(datequarter_roll,electricity_roll,'LineWidth',0.7)
    hold on
    plot(datequarter_roll,electricity_roll_fit,'LineWidth',0.7)
    rectangle('Position', [-60, 0, 2190, 600]);
    rectangle('Position', [2130, 0, 380, 600],'FaceColor',[0.05 0.05 0.05 0.05]);
    set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
    xtickformat('yyyy-MM')
    startdate = dateshift(datequarter_roll(1),'start','day',-61);
    enddate = dateshift(datequarter_roll(end),'start','day',45);
    xlim([startdate,enddate])
    title(tit(i),'FontWeight','bold','FontSize',10);
    if i==2
        legend(len,'FontSize',6,'NumColumns',4,'Orientation','horizontal','location','northwest');
        ylabel({'electricity consumption (Twh)'},'FontSize',12);
    end
    if i==3
        xlabel('Date','FontSize',12);
    end
end
annotation(gcf,'textbox',...
    [0.40 0.90 0.20 0.05],...
    'String',{'training set'},...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',12);
% Create textbox
annotation(gcf,'textbox',...
    [0.83 0.90 0.15 0.05],...
    'String','test set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',12);
savefig(gcf,'.\figure\electricity_consumption_statistic.fig');

