%% clear data and figure
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
%% read data from .csv
road4pre_dnn = readtable(".\benchmark_statistical_model_data\road4_pre_dnn.csv",'VariableNamingRule','preserve');
road4pre_dnn.Var1=[];
road4pre_dnn = table2array(road4pre_dnn);
% rnn
road4pre_rnn = readtable(".\benchmark_statistical_model_data\road4_pre_rnn.csv",'VariableNamingRule','preserve');
road4pre_rnn.Var1=[];
road4pre_rnn = table2array(road4pre_rnn);
% lstm
road4pre_lstm = readtable(".\benchmark_statistical_model_data\road4_pre_lstm.csv",'VariableNamingRule','preserve');
road4pre_lstm.Var1=[];
road4pre_lstm = table2array(road4pre_lstm);
% gru
road4pre_gru = readtable(".\benchmark_statistical_model_data\road4_pre_gru.csv",'VariableNamingRule','preserve');
road4pre_gru.Var1=[];
road4pre_gru = table2array(road4pre_gru);
%% figure setting
% figure setting
fig=figure('unit','centimeters','position',[5,5,30,15],'PaperPosition',[5, 5, 30,15],'PaperSize',[30,15]);
tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact'); % new subfigure
figbox=figure('unit','centimeters','position',[5,5,30,15],'PaperPosition',[5, 5, 30,15],'PaperSize',[30,15]);
tit={['(a) Road ',num2str(roadindex(1))],['(b) Road ',num2str(roadindex(2))],['(c) Road ',num2str(roadindex(3))],['(d) Road ',num2str(roadindex(4))]};
len={["Actual data","DNN","SRNN","LSTM","GRU","NGFM(1,1,1)"],...
    ["Actual data","DNN","SRNN","LSTM","GRU","NGFM(1,1,4)"],...
    ["Actual data","DNN","SRNN","LSTM","GRU","NGFM(1,1,3)"],...
    ["Actual data","DNN","SRNN","LSTM","GRU","NGFM(1,1,3)"]};
lenbox={["DNN","SRNN","LSTM","GRNN","NGFM(1,1,6)"],...
    ["DNN","SRNN","LSTM","GRNN","NGFM(1,1,3)"],...
    ["DNN","SRNN","LSTM","GRNN","NGFM(1,1,3)"],...
    ["DNN","SRNN","LSTM","GRNN","NGFM(1,1,5)"]};
boxcolors = [0,0.4470,0.7410;0.8500,0.3250,0.0980;0.9290,0.6940,0.1250;0.4940,0.1840,0.5560;0.4660,0.6740,0.1880];
timestart=datetime(2016,09,16,0,0,0); % from September 22st
time=dateshift(timestart,'start','hour',0:test_data_length-1);
%% begin loop
for l=1:4
    orderi=order(l,1);
    gammai=gammaopt(l,1);
    sigmai=sigmaopt(l,1);
    road_train_test=roadhour(train_test_data_index,roadsample(l));
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
    road4_test_all=repmat(road_test_all,1,5);
    road4_pre_all=[road4pre_dnn(:,l),road4pre_rnn(:,l),road4pre_lstm(:,l),road4pre_gru(:,l),road_pre_all];
    % compute mean absolute error
    mae=abs(road4_pre_all-road4_test_all);
    %
    figure(figbox)
    subplot(2,2,l)
    boxplot(mae,'Labels',lenbox{l})
    h = findobj(gca,'Tag','Box');
    for j=1:length(h)
        patch(get(h(j),'XData'),get(h(j),'YData'),boxcolors(j,:),'FaceAlpha',.5);
    end
    % boxchi = get(gca, 'Children');
    % if l==1
    %     legend(boxchi(1:5),lenbox{l})
    % end
    grid minor
    set(gca,'FontName','Book Antiqua','FontSize',10);
    ylabel({'Absolute Error'},'FontSize',10);
    title(tit(l),'FontWeight','bold','FontSize',12);
    % legend(len{l},'FontSize',8,'NumColumns',2,'Location','southeast');
    mae_pre=mean(mae,1,'omitnan');
    mae2latex(:,l)=mae_pre';
    %
    figure(fig)
    nexttile % next subfigure
    plot(time,road_test_all)
    hold on
    plot(time,road4_pre_all)
    grid on
    set(gca,'FontName','Book Antiqua','FontSize',8); % 'YLim',ylim(i,:),
    xlabel('Time','FontSize',10);
    xtickformat('yy-MM-dd')
    ylabel({'Speed (km/h)'},'FontSize',10);
    title(tit(l),'FontWeight','bold','FontSize',10);
    legend(len{l},'FontSize',8,'NumColumns',2,'Location','southeast');
end
savefig(figbox,'.\figure\compare_NN.fig');
toc