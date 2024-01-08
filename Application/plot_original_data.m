clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\roadhour.mat;
% plot
% figure setting
fig=figure('unit','centimeters','position',[5,0,30,40],'PaperPosition',[5, 0, 30,40],'PaperSize',[30,40]);
tiledlayout(4,1,'TileSpacing','Compact','Padding','Compact'); % new subfigure
tit={['(a) Road ',num2str(roadindex(1))],['(b) Road ',num2str(roadindex(2))],['(c) Road ',num2str(roadindex(3))],['(d) Road ',num2str(roadindex(4))]};
timestart=datetime(2016,08,01,0,0,0);
time=dateshift(timestart,'start','hour',0:1463);
location_train=[0, 0, 30, 50;0, 20, 30, 40;0, 0, 30, 60;0, 0, 30, 60];
location_val=[30, 0, 16, 50;30, 20, 16, 40;30, 0, 16, 60;30, 0, 16, 60];
location_test=[46, 0, 15, 50;46, 20, 15, 40;46, 0, 15, 60;46, 0, 15, 60];
for i=1:4
    nexttile
    plot(time,roadhour(1:end,roadsample(i)),'LineStyle',"-",'LineWidth',0.6,'MarkerSize',4,'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
    rectangle('Position', location_train(i,:),'FaceColor',[0.05 0.05 0.05 0.05]);
    rectangle('Position', location_val(i,:),'FaceColor',[0.9290 0.6940 0.1250 0.05]);
    rectangle('Position', location_test(i,:),'FaceColor',[.8500 0.3250 0.0980 0.10]);
    grid minor
    set(gca,'FontName','Book Antiqua','FontSize',8);
    xlim([time(1),time(end)])
    xlabel('Time','FontSize',8);
    xtickformat('yy-MM-dd')
    ylabel({'Speed (km/h)'},'FontSize',8);
    title(tit(i),'FontWeight','bold','FontSize',10);
end
% Create textbox
annotation(gcf,'textbox',...
    [0.24 0.79 0.15 0.05],...
    'String','training set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',10);
% Create textbox
annotation(gcf,'textbox',...
    [0.56 0.79 0.15 0.05],...
    'String','validation set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',10);
% Create textbox
annotation(gcf,'textbox',...
    [0.81 0.79 0.08 0.05],...
    'String','test set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',10);
savefig(gcf,'.\figure\speed_data.fig');
