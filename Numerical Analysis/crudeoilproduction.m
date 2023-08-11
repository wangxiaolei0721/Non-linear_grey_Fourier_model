clc;
clear;
close all;
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\crudeoilproduction.mat;
% data set setting
train_data_length = 180;
train_data_index = [1:train_data_length]';
val_data_length = 108;
train_val_data_index = [1:train_data_length+val_data_length]';
test_data_length = 108;
train_test_data_index = [(length(crudeoil)-test_data_length-train_data_length)+1:length(crudeoil)]';
val_step = 12;
test_step = 12;
% figure setting
figure('unit','centimeters','position',[5,5,20,15],'PaperPosition',[5, 5, 20,15],'PaperSize',[20,15]);
tit={['(a) the training data set '],['the training and validation data set '],['(c) the training and test data set ']};
tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
% plot the training data set
crudeoil_train = crudeoil(train_data_index);
date_train=date(train_data_index);
nexttile;
plot(date_train,crudeoil_train)
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
% plot the training and validation data set
crudeoil_train_val = crudeoil(train_val_data_index);
date_train_val = date(train_val_data_index);
nexttile;
plot(date_train_val,crudeoil_train_val)
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
% the training and test data set
crudeoil_train_test = crudeoil(train_test_data_index);
date_train_test = date(train_test_data_index);
nexttile;
plot(date_train_test,crudeoil_train_test)
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
savefig(gcf,'.\figure\crude_oil_data.fig');
%% determine the Fourier order
% removing trend
crudeoil_train_val_detrend = crudeoil_train_val -GM11(crudeoil_train_val,0);
figure
[ xfreq,xpower] = fourier_transform(crudeoil_train_val_detrend(2:end));
% peak detection plot
% findpeaks(xpower,xfreq,'MinPeakDistance',1/12,'MinPeakProminence',2000000);% 'Annotate','extents','prominence', 'Threshold'
plot(xfreq,xpower)
grid off
xline(xfreq(24),'--','HandleVisibility','off')
text(xfreq(24),5000000,['$\rightarrow f$=',num2str(xfreq(24))],'Interpreter','latex')
xline(xfreq(48),'--','HandleVisibility','off')
text(xfreq(48),6000000,['$\rightarrow f$=',num2str(xfreq(48))],'Interpreter','latex')
xline(xfreq(72),'--','HandleVisibility','off')
text(xfreq(72),7000000,['$\rightarrow f$=',num2str(xfreq(72))],'Interpreter','latex')
xline(xfreq(96),'--','HandleVisibility','off')
text(xfreq(96),8000000,['$\rightarrow f$=',num2str(xfreq(96))],'Interpreter','latex')
xline(xfreq(120),'--','HandleVisibility','off')
text(xfreq(120),9000000,['$\rightarrow f$=',num2str(xfreq(120))],'Interpreter','latex')
% peaks and location
[pks,locs]=findpeaks(xpower,xfreq,'MinPeakDistance',1/12,'MinPeakProminence',100000);
% maximum frequency = order * frequency
order=round(locs(end)*12);
fprintf('The optimal order is %d.\n',order)
save('.\data\crudeoilorder.mat','order')
% plot(xfreq,xpower,'color',[0, 114, 189]/255,'LineWidth',1)
set(gca,'FontName','Book Antiqua','FontSize',8);
xlabel(['Frequency'],'FontSize',10);
ylabel({'Power'},'FontSize',10);
savefig(gcf,'.\figure\crude_oil_power.fig');
%%
% model setting
omega=pi/6; % angular frequency
gammamin=1;
gammamax=500;
sigmamin=1;
sigmamax=100000;
% road i data from August 1 to August 31
oil_train_val = crudeoil(train_val_data_index);
% Upper and lower limits of variables and type settings
gamma =  optimizableVariable('gamma',  [gammamin, gammamax], 'Type', 'real');
sigma =  optimizableVariable('sigma',  [sigmamin, sigmamax], 'Type', 'real');
parameter = [gamma, sigma];
minobjfun = @(parameter) minobject(parameter,oil_train_val,omega,order,train_data_length,val_step);
% bayesian optimization
rng(100) % For reproducibility 200
iter = 50;
points = 100;
opt_results = bayesopt(minobjfun, parameter, 'Verbose', 1, ...
    'MaxObjectiveEvaluations', iter,...
    'NumSeedPoints', points);
% optimal Results
[bestParam, ~, ~] = bestPoint(opt_results, 'Criterion', 'min-observed');
gammaopt = bestParam.gamma;
sigmaopt = bestParam.sigma;
save('.\data\crudeoilhyperparameter.mat','gammaopt','sigmaopt')
% Obtain all open figure
allFigures = findall(0, 'Type', 'figure');
figure(allFigures(1))
set(gca,'FontName','Book Antiqua','FontSize',10)
title('','FontWeight','bold','FontSize',12);
% savefig(gcf,'.\figure\crude_oil_process.fig');
figure(allFigures(2))
set(gca,'FontName','Book Antiqua','FontSize',10)
title('','FontWeight','bold','FontSize',12);
% savefig(gcf,'.\figure\crude_oil_obj.fig');
%% forecasting performance
% model setting
omega=pi/6; % angular frequency
oil_train_test=crudeoil(train_test_data_index);
datalength=length(oil_train_test);
k=1;
oil_train_all=[];
oil_fit_all=[];
oil_test_all=[];
oil_pre_all=[];
figure('unit','centimeters','position',[5,5,20,15],'PaperPosition',[5, 5, 20,15],'PaperSize',[20,15]);
tit={['(a) First roll '],['(b) Second roll '],['(c) Third roll '],['(d) Fourth roll '],...
    ['(e) Fifth roll '],['(f) Sixth roll '],['(g) Third roll '],['(h) Seventh roll '],...
    ['(h) Eighth roll ']};
tit0=1;
len=["Actual data","NGFM(1,1,1)"];
tiledlayout(3,3,'TileSpacing','Compact','Padding','Compact'); % new subfigure
while (k+train_data_length+test_step-1)<=datalength
    % train data
    oil_train=oil_train_test(k:k+train_data_length-1);
    oil_train_all=[oil_train_all;oil_train];
    date_train = date_train_test(k:k+train_data_length-1);
    % test data
    oil_test=oil_train_test(k+train_data_length:k+train_data_length+test_step-1);
    oil_test_all=[oil_test_all;oil_test];
    date_test = date_train_test(k+train_data_length:k+train_data_length+test_step-1);
    % call model code
    oil_fit_pre = NGFM(oil_train,omega,order,gammaopt,sigmaopt,test_step);
    % fitting data
    oil_fit=oil_fit_pre(1:train_data_length);
    % all fitting data
    oil_fit_all=[oil_fit_all;oil_fit];
    % predictive data
    oil_pre=oil_fit_pre(train_data_length+1:end);
    % all predictive data
    oil_pre_all=[oil_pre_all;oil_pre];
    % location update
    k=k+test_step;
    % % figure setting
    nexttile;
    plot([date_train;date_test],[ oil_train;oil_test])
    hold on
    plot([date_train;date_test],oil_fit_pre)
    rectangle('Position', [0, 1000, 5480, 1000]);
    rectangle('Position', [5480, 1000, 365, 1000],'FaceColor',[0.05 0.05 0.05 0.05]);
    set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
    xtickformat('yyyy-MM')
    startdate = dateshift(date_train(1),'start','day',-15);
    enddate = dateshift(date_test(end),'start','day',45);
    xlim([startdate,enddate])
    title(tit(tit0),'FontWeight','bold','FontSize',10);
    if tit0==5
        legend(len,'FontSize',6,'NumColumns',4,'Location','south','Orientation','horizontal');
    end
    if tit0==4
        ylabel({'electricity consumption (Twh)'},'FontSize',10);
    end
    if tit0==8
        xlabel('Date','FontSize',12);
    end
    tit0=tit0+1;
end
% accuracy
mae_fit=mean(abs(oil_fit_all -  oil_train_all));
fprintf('The fitting mae is %d.\n',mae_fit)
mae_pre=mean(abs(oil_pre_all - oil_test_all));
fprintf('The predicting mae is %d.\n',mae_pre)
