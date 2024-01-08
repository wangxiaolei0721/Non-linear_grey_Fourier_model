clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\crudeoilproduction.mat;
load .\data\crudeoilorder.mat;
load .\data\crudeoilhyperparameter.mat;
% model setting
omega=pi/6; % angular frequency
train_data_length = 180;
train_data_index = [1:train_data_length]';
val_data_length = 108;
train_val_data_index = [1:train_data_length+val_data_length]';
test_data_length = 108;
train_test_data_index = [(length(crudeoil)-test_data_length-train_data_length)+1:length(crudeoil)]';
val_step = 12;
test_step = 12;
crudeoil_train_test=crudeoil(train_test_data_index);
datalength=length(crudeoil_train_test);
date_train_test = date(train_test_data_index);
k=1;
% disp(k)
crudeoil_train_all=[];
crudeoil_fit_all=[];
crudeoil_test_all=[];
crudeoil_pre_all=[];
% NGFM model
crudeoil_fit_NGFM=[];
crudeoil_pre_NGFM=[];
date_train_all=[];
date_test_all=[];
while (k+train_data_length+test_step-1)<=datalength
    % train data
    crudeoil_train=crudeoil_train_test(k:k+train_data_length-1);
    crudeoil_train_all=[crudeoil_train_all;crudeoil_train];
    date_train = date_train_test(k:k+train_data_length-1);
    date_train_all=[date_train_all; date_train];
    % test data
    crudeoil_test=crudeoil_train_test(k+train_data_length:k+train_data_length+test_step-1);
    crudeoil_test_all=[crudeoil_test_all;crudeoil_test];
    date_test = date_train_test(k+train_data_length:k+train_data_length+test_step-1);
    date_test_all=[date_test_all; date_test];
    % call model code
    crudeoil_fit_pre = NGFM(crudeoil_train,omega,order,gammaopt,sigmaopt,test_step);
    % fitting data
    crudeoil_fit=crudeoil_fit_pre(1:train_data_length);
    % all fitting data
    crudeoil_fit_NGFM=[crudeoil_fit_NGFM;crudeoil_fit];
    % predictive data
    crudeoil_pre=crudeoil_fit_pre(train_data_length+1:end);
    % all predictive data
    crudeoil_pre_NGFM=[crudeoil_pre_NGFM;crudeoil_pre];
    % location update
    k=k+test_step;
    %     disp(k)
end
% read data from R output
% ARIMA
crudeoil_fit_ARIMA = readtable("benchmark_statistical_model_data\crudeoil_fit_ARIMA.csv",'VariableNamingRule','preserve');
crudeoil_fit_ARIMA.Var1=[];
crudeoil_fit_ARIMA = table2array(crudeoil_fit_ARIMA);
crudeoil_fit_all(:,1)=crudeoil_fit_ARIMA;
crudeoil_pre_ARIMA = readtable("benchmark_statistical_model_data\crudeoil_pre_ARIMA.csv",'VariableNamingRule','preserve');
crudeoil_pre_ARIMA.Var1=[];
crudeoil_pre_ARIMA = table2array(crudeoil_pre_ARIMA);
crudeoil_pre_all(:,1)=crudeoil_pre_ARIMA;
% ets
crudeoil_fit_ets = readtable("benchmark_statistical_model_data\crudeoil_fit_ets.csv",'VariableNamingRule','preserve');
crudeoil_fit_ets.Var1=[];
crudeoil_fit_ets = table2array(crudeoil_fit_ets);
crudeoil_fit_all(:,2)=crudeoil_fit_ets;
crudeoil_pre_ets = readtable("benchmark_statistical_model_data\crudeoil_pre_ets.csv",'VariableNamingRule','preserve');
crudeoil_pre_ets.Var1=[];
crudeoil_pre_ets = table2array(crudeoil_pre_ets);
crudeoil_pre_all(:,2)=crudeoil_pre_ets;
% nnetar
crudeoil_fit_nnetar = readtable("benchmark_statistical_model_data\crudeoil_fit_nnetar.csv",'VariableNamingRule','preserve');
crudeoil_fit_nnetar.Var1=[];
crudeoil_fit_nnetar = table2array(crudeoil_fit_nnetar);
crudeoil_fit_all(:,3)=crudeoil_fit_nnetar;
crudeoil_pre_nnetar = readtable("benchmark_statistical_model_data\crudeoil_pre_nnetar.csv",'VariableNamingRule','preserve');
crudeoil_pre_nnetar.Var1=[];
crudeoil_pre_nnetar = table2array(crudeoil_pre_nnetar);
crudeoil_pre_all(:,3)=crudeoil_pre_nnetar;
% deep neural net
crudeoil_fit_dnn = NaN(size(crudeoil_fit_nnetar));
crudeoil_fit_all(:,4)=crudeoil_fit_dnn;
crudeoil_pre_dnn = readtable("benchmark_statistical_model_data\crudeoil_pre_dnn.csv",'VariableNamingRule','preserve');
crudeoil_pre_dnn.Var1=[];
crudeoil_pre_dnn = table2array(crudeoil_pre_dnn);
crudeoil_pre_all(:,4)=crudeoil_pre_dnn;
%
crudeoil_fit_all(:,5)=crudeoil_fit_NGFM;
crudeoil_pre_all(:,5)=crudeoil_pre_NGFM;
% compute mean absolute error
mae_fit=mean(abs(crudeoil_fit_all-repmat(crudeoil_train_all,1,5)),1,'omitnan');
mae_pre=mean(abs(crudeoil_pre_all-repmat(crudeoil_test_all,1,5)),1,'omitnan');
mae2latex(1,:)=mae_fit;
mae2latex(2,:)=mae_pre;
% figure setting
figure('unit','centimeters','position',[0,0,29,35],'PaperPosition',[0,0,29,35],'PaperSize',[29,35]);
tit={['(a) First roll '],['(b) Second roll '],['(c) Third roll '],['(d) Fourth roll '],...
    ['(e) Fifth roll '],['(f) Sixth roll '],['(g) Third roll '],['(h) Seventh roll '],...
    ['(h) Eighth roll ']};
tit0=1;
col_matrix = [0,0,0;
    87, 103, 250;
    160, 98, 205;
    150, 233, 130;
    240, 163, 70;
    239, 55, 81]/255;
colororder(col_matrix);
len=["Actual data","SARIMA","ES","NNAR","DNN","NGFM(1,1,5)"];
tiledlayout(3,3,'TileSpacing','Compact','Padding','Compact'); % new subfigure
for i=1:9
    nexttile;
    date_roll=[date_train_all((i-1)*train_data_length+1:i*train_data_length);date_test_all((i-1)*test_step+1:i*test_step)];
    crudeoil_roll=[crudeoil_train_all((i-1)*train_data_length+1:i*train_data_length);crudeoil_test_all((i-1)*test_step+1:i*test_step)];
    crudeoil_roll_fit=[crudeoil_fit_all((i-1)*train_data_length+1:i*train_data_length,:);crudeoil_pre_all((i-1)*test_step+1:i*test_step,:)];
    plot(date_roll,crudeoil_roll,'LineWidth',0.3)
    hold on
    plot(date_roll,crudeoil_roll_fit,'LineWidth',0.3)
    if tit0==2 && tit0==3
        legend(len,'FontSize',4,'NumColumns',3,'Location','southwest','Orientation','horizontal');
    else
        rectangle('Position', [0, 1000, 5480, 1200]);
        rectangle('Position', [5480, 1000, 365, 1200],'FaceColor',[0.05 0.05 0.05 0.05]);
    end
    set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
    xtickformat('yyyy-MM')
    startdate = dateshift(date_roll(1),'start','day',-15);
    enddate = dateshift(date_roll(end),'start','day',45);
    xlim([startdate,enddate])
    title(tit(tit0),'FontWeight','bold','FontSize',10);
    if tit0==5
        legend(len,'FontSize',4,'NumColumns',3,'Location','southwest','Orientation','horizontal');
    end
    if tit0==4
        ylabel({'electricity consumption (Twh)'},'FontSize',10);
    end
    if tit0==8
        xlabel('Date','FontSize',12);
    end
    tit0=tit0+1;
end
annotation(gcf,'textbox',...
    [0.45 0.90 0.15 0.05],...
    'String',{'training set'},...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',12);
savefig(gcf,'.\figure\crude_oil_statistic.fig');
