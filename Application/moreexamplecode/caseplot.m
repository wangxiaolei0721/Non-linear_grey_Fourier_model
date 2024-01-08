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
test_data=[1105:length(roadhour)]'; % from September 15st to 30th
train=7*24;
test=24;
% figure setting
fig=figure('unit','centimeters','position',[5,0,20,40],'PaperPosition',[5, 0, 20,40],'PaperSize',[20,40]);
tiledlayout(4,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
% tit={['Road ',num2str(roadindice(1))]};
% len={["Actual data","GFM(1,1,2)","DGFM(1,1,2)","NGFM(1,1,2)"]};
timestart=datetime(2016,09,16,0,0,0); % from September 22st
time=dateshift(timestart,'start','hour',0:359); 

% begin loop
for l=1:4
    orderi=order(l,1);
    gammai=gamma(l,1);
    sigmai=sigma(l,1);
    road_train_test=roadhour(test_data,roadsample(l));
    
    nexttile % next subfigure
    plot(time,road_train_test)
    grid on
    set(gca,'FontName','Book Antiqua','FontSize',8); % 'YLim',ylim(i,:),
    xlabel('Time','FontSize',10);
    xtickformat('yy-MM-dd')
    ylabel({'Speed (km/h)'},'FontSize',10);
    % title(tit(l),'FontWeight','bold','FontSize',10);
    % legend(len{l},'FontSize',8,'NumColumns',3,'Location','southeast');
end
savefig(gcf,'.\figure\compare_linear_grey_Fourier_model.fig');
% exportgraphics(gcf,'F:\博士\Nonlinear grey Fourier model\figure\compare_grey.pdf')
toc