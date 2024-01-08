clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Modelcode')
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
fig=figure('unit','centimeters','position',[2,2,15,15],'PaperPosition',[2, 2, 15,15],'PaperSize',[15,15]);
tit={['(a) First roll '],['(b) Second roll '],['(c) Third roll '],['(d) Fourth roll '] };
tit0=1;
col_matrix = [0,0,0;
    87, 103, 250;
    160, 98, 205;
    60, 191, 255;
    150, 233, 130;
    240, 163, 70;
    239, 55, 81]/255;
colororder(col_matrix);
len=["Actual data","GM(1,1|cos,sin)","DGGM(1,1)","SGM(1,1)","GFM(1,1,1)","DGFM(1,1,1)","NGFM(1,1,1)"];
tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
while (k+train_data_length+test_step-1)<=datalength
    % train data
    electricity_train=electricity_train_test(k:k+train_data_length-1);
    electricity_train_all=[electricity_train_all;electricity_train];
    datequarter_train = datequarter_train_test(k:k+train_data_length-1);
    % test data
    electricity_test=electricity_train_test(k+train_data_length:k+train_data_length+test_step-1);
    electricity_test_all=[electricity_test_all;electricity_test];
    datequarter_test = datequarter_train_test(k+train_data_length:k+train_data_length+test_step-1);
    % call model code
    electricity_fit_pre(:,1) = GM11_Gurcan(electricity_train,omega,test_step);
    electricity_fit_pre(:,2) = DGGM(electricity_train,omega,test_step);
    electricity_fit_pre(:,3) = SGM(electricity_train,omega,test_step);
    electricity_fit_pre(:,4) = GFM_linear_integral(electricity_train,omega,order,test_step); % SGM(road_train,omega,test_step);
    electricity_fit_pre(:,5) = DGFM(electricity_train,omega,order,test_step);
    electricity_fit_pre(:,6) = NGFM(electricity_train,omega,order,gammaopt,sigmaopt,test_step);
    % fitting data
    electricity_fit=electricity_fit_pre(1:train_data_length,:);
    % all fitting data
    electricity_fit_all=[electricity_fit_all;electricity_fit];
    % predictive data
    electricity_pre=electricity_fit_pre(train_data_length+1:end,:);
    % all predictive data
    electricity_pre_all=[electricity_pre_all;electricity_pre];
    % location update
    k=k+test_step;
    %     disp(k)
    % figure setting
    nexttile;
    plot([datequarter_train;datequarter_test],[ electricity_train;electricity_test],'LineWidth',0.7)
    hold on
    plot([datequarter_train;datequarter_test],electricity_fit_pre,'LineWidth',0.7)
    rectangle('Position', [-60, 0, 2190, 600]);
    rectangle('Position', [2130, 0, 380, 600],'FaceColor',[0.05 0.05 0.05 0.05]);
    set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
    xtickformat('yyyy-MM')
    startdate = dateshift(datequarter_train(1),'start','day',-61);
    enddate = dateshift(datequarter_test(end),'start','day',45);
    xlim([startdate,enddate])
    title(tit(tit0),'FontWeight','bold','FontSize',10);
    if tit0==2
        legend(len,'FontSize',6,'NumColumns',4,'Orientation','horizontal','location','northwest');
        ylabel({'electricity consumption (Twh)'},'FontSize',12);
    end
    if tit0==3
        xlabel('Date','FontSize',12);
    end
    tit0=tit0+1;
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
% compute mean absolute error
mae_fit=mean(abs(electricity_fit_all-repmat(electricity_train_all,1,1)),1,'omitnan');
mae_pre=mean(abs(electricity_pre_all-repmat(electricity_test_all,1,1)),1,'omitnan');
mae2latex(1,:)=mae_fit;
mae2latex(2,:)=mae_pre;
savefig(gcf,'.\figure\electricity_consumption_grey.fig');
