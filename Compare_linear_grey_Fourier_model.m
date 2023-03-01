% clear data and figure
clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Non-linear grey Fourier model','.\benchmark_grey_model')
% load data
load .\data\roadhour.mat;
load .\data\order.mat;
load .\data\parameter.mat;
% model setting
omega=pi/12; % angular frequency
case_train_test=[(51*24+1):(51*24+192)]'; % % road 187 from September 21 to 30
train=7*24;
test=24;
% figure setting
fig=figure('unit','centimeters','position',[5,5,20,12],'PaperPosition',[5, 5,20,12],'PaperSize',[20,12]);
tit={['Road ',num2str(roadindice(2))]};
len=["Actual data","GFM(1,1,2)","DGFM(1,1,2)","NGFM(1,1,2)"];
timestart=datetime(2016,09,21,0,0,0); % from September 22st
time=dateshift(timestart,'start','hour',0:191);
orderi=order(2,1); % road 187
gammai=gamma(2,1); % road 187
sigmai=sigma(2,1); % road 187
case_data=roadhour(case_train_test,roadsample(2));
case_train_data=case_data(1:train);
case_test_data=case_data((train+1):(train+24));
case_fit_pre(:,1) = GFM_linear_integral(case_train_data,omega,orderi,test); % SGM(road_train,omega,test);
case_fit_pre(:,2) = DGFM(case_train_data,omega,orderi,test);
case_fit_pre(:,3) = NGFM(case_train_data,omega,orderi,gammai,sigmai,test);
plot(time,case_data,'LineWidth',0.5,'Marker','*')
hold on
plot(time,case_fit_pre,'LineWidth',1)
grid on
set(gca,'FontName','Book Antiqua','FontSize',8); % 'YLim',ylim(i,:),
xlabel('Time','FontSize',10);
xtickformat('yy-MM-dd')
ylabel({'Speed (km/h)'},'FontSize',10);
title(tit,'FontWeight','bold','FontSize',10);
legend(len,'FontSize',8,'NumColumns',2,'Location','Northeast');
savefig(gcf,'.\figure\compare_linear_grey_Fourier_model.fig');
toc