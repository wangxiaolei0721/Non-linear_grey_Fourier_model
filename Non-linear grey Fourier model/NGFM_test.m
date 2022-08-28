clc;
clear;
close all;
%% add path to MATLAB
addpath('..\model')
load roadhour.mat
omega=pi/12; % angular frequency
order=5; % Fourier order
gamma=5; % gamma
sigma=300;  % sigma
test=24;
x=roadhour(1:168,6);
x_fit_pre= NGFM(x,omega,order,gamma,sigma,test);
figure
plot(x)
hold on
plot(x_fit_pre)
hold off
