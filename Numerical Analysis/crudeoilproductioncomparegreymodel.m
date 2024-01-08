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
crudeoil_train_all=[];
crudeoil_fit_all=[];
crudeoil_test_all=[];
crudeoil_pre_all=[];
figure('unit','centimeters','position',[0,0,29,35],'PaperPosition',[0,0,29,35],'PaperSize',[29,35]);
tit={['(a) First roll '],['(b) Second roll '],['(c) Third roll '],['(d) Fourth roll '],...
    ['(e) Fifth roll '],['(f) Sixth roll '],['(g) Third roll '],['(h) Seventh roll '],...
    ['(h) Eighth roll ']};
tit0=1;
col_matrix = [0,0,0;
    87, 103, 250;
    160, 98, 205;
    60, 191, 255;
    150, 233, 130;
    240, 163, 70;
    239, 55, 81]/255;
colororder(col_matrix);
len=["Actual data","GM(1,1|cos,sin)","DGGM(1,1)","SGM(1,1)","GFM(1,1,5)","DGFM(1,1,5)","NGFM(1,1,5)"];
tiledlayout(3,3,'TileSpacing','Compact','Padding','Compact'); % new subfigure
while (k+train_data_length+test_step-1)<=datalength
    % train data
    crudeoil_train=crudeoil_train_test(k:k+train_data_length-1);
    crudeoil_train_all=[crudeoil_train_all;crudeoil_train];
    date_train = date_train_test(k:k+train_data_length-1);
    % test data
    crudeoil_test=crudeoil_train_test(k+train_data_length:k+train_data_length+test_step-1);
    crudeoil_test_all=[crudeoil_test_all;crudeoil_test];
    date_test = date_train_test(k+train_data_length:k+train_data_length+test_step-1);
    % call model code
    crudeoil_fit_pre(:,1) = GM11_Gurcan(crudeoil_train,omega,test_step);
    crudeoil_fit_pre(:,2) = DGGM(crudeoil_train,omega,test_step);
    crudeoil_fit_pre(:,3) = SGM(crudeoil_train,omega,test_step);
    crudeoil_fit_pre(:,4) = GFM_linear_integral(crudeoil_train,omega,order,test_step); % SGM(road_train,omega,test);
    crudeoil_fit_pre(:,5) = DGFM(crudeoil_train,omega,order,test_step);
    crudeoil_fit_pre(:,6) = NGFM(crudeoil_train,omega,order,gammaopt,sigmaopt,test_step);
    % fitting data
    crudeoil_fit=crudeoil_fit_pre(1:train_data_length,:);
    % all fitting data
    crudeoil_fit_all=[crudeoil_fit_all;crudeoil_fit];
    % predictive data
    crudeoil_pre=crudeoil_fit_pre(train_data_length+1:end,:);
    % all predictive data
    crudeoil_pre_all=[crudeoil_pre_all;crudeoil_pre];
    % location update
    k=k+test_step;
    %     disp(k)
    % figure setting
    nexttile;
    plot([date_train;date_test],[ crudeoil_train;crudeoil_test],'LineWidth',0.3)
    hold on
    plot([date_train;date_test],crudeoil_fit_pre,'LineWidth',0.3)
    rectangle('Position', [0, 1000, 5480, 1000]);
    rectangle('Position', [5480, 1000, 365, 1000],'FaceColor',[0.05 0.05 0.05 0.05]);
    set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
    xtickformat('yyyy-MM')
    startdate = dateshift(date_train(1),'start','day',-15);
    enddate = dateshift(date_test(end),'start','day',45);
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
% compute mean absolute error
mae_fit=mean(abs(crudeoil_fit_all-repmat(crudeoil_train_all,1,6)),1,'omitnan');
mae_pre=mean(abs(crudeoil_pre_all-repmat(crudeoil_test_all,1,6)),1,'omitnan');
mae2latex(1,:)=mae_fit;
mae2latex(2,:)=mae_pre;
% save
savefig(gcf,'.\figure\crude_oil_grey.fig');

