clc;
clear;
close all;
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\electricityconsumption.mat;
% data set setting
train_data_length = 24;
train_data_index = [1:train_data_length]';
val_data_length = 16;
train_val_data_index = [1:train_data_length+val_data_length]';
test_data_length = 12;
train_test_data_index = [(length(electricityquarter)-test_data_length-train_data_length)+1:length(electricityquarter)]';
val_step = 4;
test_step = 4;
% figure setting
figure('unit','centimeters','position',[5,5,20,15],'PaperPosition',[5, 5, 20,15],'PaperSize',[20,15]);
tit={['(a) the training data set '],['the training and validation data set '],['(c) the training and test data set ']};
tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
% plot the training data set
electricity_train = electricityquarter(train_data_index);
datequarter_train=datequarter(train_data_index);
nexttile;
plot(datequarter_train,electricity_train)
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
% plot the training and validation data set
electricity_train_val = electricityquarter(train_val_data_index);
datequarter_train_val = datequarter(train_val_data_index);
nexttile;
plot(datequarter_train_val,electricity_train_val)
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
% the training and test data set
electricity_train_test = electricityquarter(train_test_data_index);
datequarter_train_test = datequarter(train_test_data_index);
nexttile;
plot(datequarter_train_test,electricity_train_test)
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
savefig(gcf,'.\figure\electricity_consumption_data.fig');
%% determine the Fourier order
% removing trend
electricity_train_val_detrend = electricity_train_val - GM11(electricity_train_val,0);
figure
[ xfreq,xpower] = fourier_transform(electricity_train_val_detrend(2:end));
% peak detection plot
% findpeaks(xpower,xfreq,'MinPeakDistance',1/4,'MinPeakProminence',100000);% 'Annotate','extents','prominence', 'Threshold'
plot(xfreq,xpower)
grid off
xline(xfreq(10),'--','HandleVisibility','off')
text(xfreq(10),500000,['$\rightarrow f$=',num2str(xfreq(10))],'Interpreter','latex')
% peaks and location
[pks,locs]=findpeaks(xpower,xfreq,'MinPeakDistance',1/4,'MinPeakProminence',100000);
% maximum frequency = order * frequency
order=round(locs(end)*4);
fprintf('The optimal order is %d.\n',order)
save('.\data\electricityorder.mat','order')
% plot(xfreq,xpower,'color',[0, 114, 189]/255,'LineWidth',1)
set(gca,'FontName','Book Antiqua','FontSize',8);
xlabel(['Frequency'],'FontSize',10);
ylabel({'Power'},'FontSize',10);
savefig(gcf,'.\figure\electricity_consumption_power.fig');
%% model setting
omega=pi/2; % angular frequency
gammamin=0.1;
gammamax=200;
sigmamin=1;
sigmamax=2000;
% Upper and lower limits of variables and type settings
gamma =  optimizableVariable('gamma',  [gammamin, gammamax], 'Type', 'real');
sigma =  optimizableVariable('sigma',  [sigmamin, sigmamax], 'Type', 'real');
parameter = [gamma, sigma];
minobjfun = @(parameter) minobject(parameter,electricity_train_val,omega,order,train_data_length,val_step);
% bayesian optimization
rng(1) % For reproducibility
iter = 50;
points = 100;
opt_results = bayesopt(minobjfun, parameter, 'Verbose', 1, ...
    'MaxObjectiveEvaluations', iter,...
    'NumSeedPoints', points);
% optimal Results
[bestParam, ~, ~] = bestPoint(opt_results, 'Criterion', 'min-observed');
gammaopt = bestParam.gamma;
disp(['the optimized gamma is ',num2str(gammaopt)]);
sigmaopt = bestParam.sigma;
disp(['the optimized sigma is ',num2str(sigmaopt)]);
save('.\data\electricityhyperparameter.mat','gammaopt','sigmaopt')
% Obtain all open figure
allFigures = findall(0, 'Type', 'figure');
figure(allFigures(1));
set(gca,'FontName','Book Antiqua','FontSize',10)
% savefig(gcf,'.\figure\electricity_consumption_process.fig');
figure(allFigures(2));
set(gca,'FontName','Book Antiqua','FontSize',10)
% savefig(gcf,'.\figure\electricity_consumption_obj.fig');
%% forecasting performance
% model setting
omega=pi/2; % angular frequency
% order=1; % optional order
% order=2; % optional order
electricity_train_test=electricityquarter(train_test_data_index);
datalength=length(electricity_train_test);
k=1;
electricity_train_all=[];
electricity_fit_all=[];
electricity_test_all=[];
electricity_pre_all=[];
figure('unit','centimeters','position',[5,5,20,15],'PaperPosition',[5, 5, 20,15],'PaperSize',[20,15]);
tit={['(a) First roll '],['(b) Second roll '],['(c) Third roll '],['(d) Fourth roll '] };
tit0=1;
len=["Actual data","NGFM(1,1,1)"];
tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
while (k+train_data_length +test_step-1)<=datalength
    % train data
    electricity_train=electricity_train_test(k:(k+train_data_length -1));
    electricity_train_all=[electricity_train_all;electricity_train];
    datequarter_train = datequarter_train_test(k:k+train_data_length-1);
    % test data
    electricity_test=electricity_train_test((k+train_data_length):(k+train_data_length +test_step-1));
    electricity_test_all=[electricity_test_all;electricity_test];
    datequarter_test = datequarter_train_test(k+train_data_length:k+train_data_length+test_step-1);
    % call model code
    electricity_fit_pre = NGFM(electricity_train,omega,order,gammaopt,sigmaopt,test_step);
    % fitting data
    electricity_fit=electricity_fit_pre(1:train_data_length);
    % all fitting data
    electricity_fit_all=[electricity_fit_all;electricity_fit];
    % predictive data
    electricity_pre=electricity_fit_pre(train_data_length +1:end);
    % all predictive data
    electricity_pre_all=[electricity_pre_all;electricity_pre];
    % location update
    k=k+test_step;
    % figure setting
    nexttile;
    plot([datequarter_train;datequarter_test],[ electricity_train;electricity_test])
    hold on
    plot([datequarter_train;datequarter_test],electricity_fit_pre)
    rectangle('Position', [-55, 0, 2185, 600]);
    rectangle('Position', [2130, 0, 380, 600],'FaceColor',[0.05 0.05 0.05 0.05]);
    set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
    xlabel('Date','FontSize',12);
    xtickformat('yyyy-MM')
    startdate = dateshift(datequarter_train(1),'start','day',-61);
    enddate = dateshift(datequarter_test(end),'start','day',45);
    xlim([startdate,enddate])
    ylabel({'electricity consumption (Twh)'},'FontSize',10);
    title(tit(tit0),'FontWeight','bold','FontSize',10);
    if tit0==3
        legend(len,'FontSize',6,'NumColumns',4,'Location','south','Orientation','horizontal');
    end
    tit0=tit0+1;
end
% accuracy
mae_fit=mean(abs(electricity_fit_all -  electricity_train_all));
fprintf('The fitting mae is %d.\n',mae_fit)
mae_pre=mean(abs(electricity_pre_all - electricity_test_all));
fprintf('The predicting mae is %d.\n',mae_pre)
