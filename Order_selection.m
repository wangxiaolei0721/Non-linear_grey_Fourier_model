clc;
clear;
close all;
%% order selection
% load data
load .\data\roadhour.mat;
% figure setting
fig=figure('unit','centimeters','position',[5,5,30,15],'PaperPosition',[5, 5, 30,15],'PaperSize',[30,15]);
tit={['(a) Road ',num2str(roadindice(1))],['(b) Road ',num2str(roadindice(2))],['(c) Road ',num2str(roadindice(3))],['(d) Road ',num2str(roadindice(4))]};
tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact'); % new subfigure
Prominence=[500000,500000,500000,500000];
order=zeros(4,1);
train_val_data=[1:1104]'; % from August 1st to September 15th
% begin loop
for i = 1:4 % road1 to road4
    road_train_val=roadhour(train_val_data,roadsample(i));
    nexttile % next subfigure
    [ xfreq,xpower]=fourier_transform(road_train_val);
    % peak detection plot
    findpeaks(xpower,xfreq,'MinPeakDistance',1/24,'MinPeakProminence',Prominence(i));% 'Annotate','extents','prominence', 'Threshold'
    grid off
    if i==1
        xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),6000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(92),'--','HandleVisibility','off')
        text(xfreq(92),4000000,['$\rightarrow f$=',num2str(xfreq(92))],'Interpreter','latex')
    elseif i==2
        xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),2000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(92),'--','HandleVisibility','off')
        text(xfreq(92),800000,['$\rightarrow f$=',num2str(xfreq(92))],'Interpreter','latex')
    elseif i==3
        xline(xfreq(46),'--','HandleVisibility','off')
        text(xfreq(46),30000000,['$\rightarrow f$=',num2str(xfreq(46))],'Interpreter','latex')
        xline(xfreq(138),'--','HandleVisibility','off')
        text(xfreq(138),8000000,['$\rightarrow f$=',num2str(xfreq(138))],'Interpreter','latex')
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
    fprintf('The optimal order of the %d-th road is %d.\n',roadindice(i),orderi)
    % plot(xfreq,xpower,'color',[0, 114, 189]/255,'LineWidth',1)
    set(gca,'FontName','Book Antiqua','FontSize',8);
    xlabel(['Frequency'],'FontSize',10);
    ylabel({'Power'},'FontSize',10);
    title(tit(i),'FontWeight','bold','FontSize',10);
end
save('.\data\order.mat','order')
% save figure
savefig(gcf,'.\figure\order.fig');

%% fast fourier transform function
function [freq,power] = fourier_transform(x)
y = fft(x); % fast fourier transform
y(1) = [];
n = length(y);
power = abs(y(1:floor(n/2))).^2; % power of first half of transform data
maxfreq = 1/2;                   % maximum frequency
freq = (1:n/2)/(n/2)*maxfreq;    % equally spaced frequency grid
end