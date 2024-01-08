% order selection
clc;
clear;
close all;
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\roadhour.mat;
% data set setting
train_data_length = 30*24; % 31*24
val_data_length = 16*24; % 7*24
% from August 1st to September 15th
train_val_data_index = [1:train_data_length+val_data_length]';
% test_data_length = 15*24;
% train_test_data_index = [(length(roadhour)-test_data_length-train_data_length)+1:length(roadhour)]';
% val_step = 24;
% test_step = 24;
% figure setting
fig=figure('unit','centimeters','position',[5,5,30,15],'PaperPosition',[5, 5, 30,15],'PaperSize',[30,15]);
tit={['(a) Road ',num2str(roadindex(1))],['(b) Road ',num2str(roadindex(2))],['(c) Road ',num2str(roadindex(3))],['(d) Road ',num2str(roadindex(4))]};
tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact'); % new subfigure
Prominence=[50000,50000,500000,500000];
order=zeros(4,1);
% begin loop
for i = 1:4 % road1 to road4
    road_train_val=roadhour(train_val_data_index,roadsample(i));
    nexttile % next subfigure
    [ xfreq,xpower]=fourier_transform(road_train_val);
    % peak detection plot
    findpeaks(xpower,xfreq,'MinPeakDistance',1/24,'MinPeakProminence',Prominence(i));% 'Annotate','extents','prominence', 'Threshold'
    set(findall(gcf,'type','line'),'linewidth',1)
    grid off
    if i==1
        xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),6000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(92),'--','HandleVisibility','off')
        text(xfreq(92),4000000,['$\rightarrow f$=',num2str(xfreq(92))],'Interpreter','latex')
        xline(xfreq(46*3),'--','HandleVisibility','off')
        text(xfreq(46*3),3000000,['$\rightarrow f$=',num2str(xfreq(46*3))],'Interpreter','latex')
        xline(xfreq(46*5),'--','HandleVisibility','off')
        text(xfreq(46*5),2000000,['$\rightarrow f$=',num2str(xfreq(46*5))],'Interpreter','latex')
        xline(xfreq(46*6),'--','HandleVisibility','off')
        text(xfreq(46*6),1000000,['$\rightarrow f$=',num2str(xfreq(46*6))],'Interpreter','latex')
    elseif i==2
        xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),2000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(92),'--','HandleVisibility','off')
        text(xfreq(92),1000000,['$\rightarrow f$=',num2str(xfreq(92))],'Interpreter','latex')
        xline(xfreq(46*3),'--','HandleVisibility','off')
        text(xfreq(46*3),3000000,['$\rightarrow f$=',num2str(xfreq(46*3))],'Interpreter','latex')
    elseif i==3
        xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),30000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(46*3),'--','HandleVisibility','off')
        text(xfreq(46*3),3000000,['$\rightarrow f$=',num2str(xfreq(46*3))],'Interpreter','latex')
    elseif i==4
       xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),50000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(92),'--','HandleVisibility','off')
        text(xfreq(92),40000000,['$\rightarrow f$=',num2str(xfreq(92))],'Interpreter','latex')
        xline(xfreq(138),'--','HandleVisibility','off')
        text(xfreq(138),30000000,['$\rightarrow f$=',num2str(xfreq(138))],'Interpreter','latex')
        xline(xfreq(184),'--','HandleVisibility','off')
        text(xfreq(184),20000000,['$\rightarrow f$=',num2str(xfreq(184))],'Interpreter','latex')
        xline(xfreq(230),'--','HandleVisibility','off')
        text(xfreq(230),10000000,['$\rightarrow f$=',num2str(xfreq(230))],'Interpreter','latex')
    else
        disp("error")
    end
    % peaks and location
    [pks,locs]=findpeaks(xpower,xfreq,'MinPeakDistance',1/24,'MinPeakProminence',Prominence(i));
    % maximum frequency = order * frequency
    orderi=round(locs(end)*24);
    % store optimal order
    order(i,1)= orderi;
    fprintf('The optimal order of the %d-th road is %d.\n',roadindex(i),orderi)
    % plot(xfreq,xpower,'color',[0, 114, 189]/255,'LineWidth',1)
    set(gca,'FontName','Book Antiqua','FontSize',10);
    xlabel(['Frequency'],'FontSize',10);
    ylabel({'Power'},'FontSize',10);
    title(tit(i),'FontWeight','bold','FontSize',12);
end
save('.\data\order.mat','order')
% save figure
savefig(gcf,'.\figure\order.fig');