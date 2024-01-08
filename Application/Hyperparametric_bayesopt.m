clc;
clear;
close all;
tic
% add path to MATLAB
addpath('..\Modelcode')
% load data
load .\data\roadhour.mat;
load .\data\order.mat;
% data set setting
train_data_length = 30*24;
val_data_length = 16*24;
% from August 1st to September 15th
train_val_data_index = [1:train_data_length+val_data_length]';
% test_data_length = 15*24;
% train_test_data_index = [(length(roadhour)-test_data_length-train_data_length)+1:length(roadhour)]';
val_step = 24;
% test_step = 24;
% model setting
omega=pi/12; % angular frequency
gammamin=[0.01;0.01;0.01;0.01];
gammamax=[100;100;100;100];
sigmamin=[1;1;1;1];
sigmamax=[200;200;200;200];
gammaopt=zeros(4,1);
sigmaopt=zeros(4,1);
rng('default') % For reproducibility
% begin loop
for l=1:4
    % the optimal order corresponding to road i
    orderi=order(l,1);
    % road i data from August 1 to August 31
    road_train_val=roadhour(train_val_data_index,roadsample(l));
    % Upper and lower limits of variables and type settings
    gamma =  optimizableVariable('gamma',  [gammamin(l), gammamax(l)], 'Type', 'real');
    sigma =  optimizableVariable('sigma',  [sigmamin(l), sigmamax(l)], 'Type', 'real');
    parameter = [gamma, sigma];
    minobjfun = @(parameter) minobject(parameter,road_train_val,omega,orderi,train_data_length,val_step);
    % bayesian optimization
    rng(0) % For reproducibility 200
    iter = 50;
    points = 100;
    opt_results = bayesopt(minobjfun, parameter, 'Verbose', 1, ...
        'MaxObjectiveEvaluations', iter,...
        'NumSeedPoints', points);
    % optimal Results
    [bestParam, ~, ~] = bestPoint(opt_results, 'Criterion', 'min-observed');
    gammaopt(l,1) = bestParam.gamma;
    sigmaopt(l,1) = bestParam.sigma;
end
save('.\data\parameter.mat','gammaopt','sigmaopt');
%% save figure
tit={['(a) Road ',num2str(roadindex(1))],['(a) Road ',num2str(roadindex(1))] ...
    ['(b) Road ',num2str(roadindex(2))],['(b) Road ',num2str(roadindex(2))] ...
    ['(c) Road ',num2str(roadindex(3))],['(c) Road ',num2str(roadindex(3))] ...
    ['(d) Road ',num2str(roadindex(4))],['(d) Road ',num2str(roadindex(4))]};
% Obtain all open figure
allFigures = findall(0, 'Type', 'figure');
for i = 1:numel(allFigures)
    j=numel(allFigures)-i+1;
    figure(allFigures(j));
    set(gca,'FontName','Book Antiqua','FontSize',10)
    title(tit(j),'FontWeight','bold','FontSize',12);
end
% savefig(gcf,'.\figure\hyperparopt.fig');
toc
