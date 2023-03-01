function x_fit = SGM( x,omega,f)
% data group method
% input:
% x: time series data
% omega: angular frequency
% f: predicted step
% output:
% x_fit: fitting and predicting data
% reference:
% Zheng-Xin Wang, Qin Li, Ling-Ling Pei.
% A seasonal GM(1,1) model for forecasting the electricity consumption of the primary economic sectors,
% Energy,2018,154:522-534.
%% parameter setting
T=2*pi/omega; % periodic period
time=[1:length(x)];
xmean=mean(x); % mean of x
%% compute seasonal index
for i=0:T-1
    index=time(mod(time,T)==i); % data index
    season(i+1,:)=mean(x(index))/xmean;
end
%% generate seasonal series
for j=1:length(x)+f
    season_index(j,1)=season(mod(j,T)+1);
end
detrend=x./season_index(1:length(x));
x_fit_gm11=GM11(detrend,f);
x_fit=x_fit_gm11.*season_index;
end