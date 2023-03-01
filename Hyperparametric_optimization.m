clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Non-linear grey Fourier model')
% load data
load .\data\roadhour.mat;
load .\data\order.mat;
% model setting
omega=pi/12; % angular frequency
gammamin=[0.1;0.1;0.1;0.1];
gammastep=[0.1;0.1;0.1;0.1];
gammamax=[5;5;5;5];
sigmamin=[1;1;1;1];
sigmastep=[5;5;5;5];
sigmamax=[101;101;101;101];
train=7*24;
val=24;
% figure setting
fig=figure('unit','centimeters','position',[5,5,30,15],'PaperPosition',[5, 5, 30,15],'PaperSize',[30,15]);
tit={['(a) Road ',num2str(roadindice(1))],['(b) Road ',num2str(roadindice(2))],['(c) Road ',num2str(roadindice(3))],['(d) Road ',num2str(roadindice(4))]};
tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact'); % new subfigure
gamma=zeros(4,1);
sigma=zeros(4,1);
train_val_data=[1:1104]'; % from August 1st to September 15th
% begin loop
for l=1:4
    % the optimal order corresponding to road i
    orderi=order(l,1);
    % road i data from August 1 to August 31
    road_train_val=roadhour(train_val_data,roadsample(l));
    % meshgrid gamma and sigma
    gammainterval=[gammamin(l):gammastep(l):gammamax(l)]; % gamma
    sigmainterval=[sigmamin(l):sigmastep(l):sigmamax(l)];  % sigma
    [gammax,sigmay]=meshgrid(gammainterval,sigmainterval);
    [row,col]=size(gammax);
    road_val_all=[];
    road_pre_all=[];
    mae=zeros(row,col);
    % show calculating progress
    progress=waitbar(0,'Calculating, please wait!');
    for i=1:row
        for j=1:col
            k=1; % Mark the first position of the data to be calculated
            % String displayed by progress bar
            str=['Calculate progress for the road ',num2str(roadindice(l)),':',num2str(((i-1)*col+j)/(row*col)*100),'%'];
            % show progress bar
            waitbar(((i-1)*col+j)/(row*col),progress,str);
            % while the last used data less than the data length
            while (k+train+val-1)<=1104
                % train data
                road_train=road_train_val(k:k+train-1);
                % validation data
                road_val=road_train_val(k+train:k+train+val-1);
                % all validation data
                road_val_all=[road_val_all;road_val];
                % call model code
                road_fit_pre = NGFM(road_train,omega,orderi,gammax(i,j),sigmay(i,j),val);
                % predictive data
                road_pre=road_fit_pre(train+1:end);
                % all predictive data
                road_pre_all=[road_pre_all;road_pre];
                % location update
                k=k+val;
            end
            mae(i,j)=mean(abs(road_pre_all-road_val_all));
        end
    end
    close(progress);
    nexttile % next subfigure
    % plot 3D surface
    mesh(gammax,sigmay,mae)
    set(gca,'FontName','Book Antiqua','FontSize',8);
    xlabel(['\gamma'],'FontSize',10);
    ylabel({'\sigma'},'FontSize',10);
    zlabel({'mean absolute error'},'FontSize',10);
    title(tit(l),'FontWeight','bold','FontSize',10);
    % minimal mae
    minmae=min(mae,[],'all');
    % row indice and column indice corresponding to minimal mae
    [minx,miny]=find(mae==minmae);
    % gamma optimization value
    gammaopt=gammax(minx,miny);
    fprintf('The optimal gamma of the %d-th road is %d.\n',roadindice(l),gammaopt)
    gamma(l,1)=gammaopt;
    % sigma optimization value
    sigmaopt=sigmay(minx,miny);
    fprintf('The optimal sigma of the %d-th road is %d.\n',roadindice(l),sigmaopt)
    sigma(l,1)=sigmaopt;
end
save('.\data\parameter.mat','gamma','sigma');
%% save figure
savefig(gcf,'.\figure\hyperparopt.fig');
toc