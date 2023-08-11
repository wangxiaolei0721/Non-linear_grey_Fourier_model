function x_fit = DGGM( x,omega,f)
% data group method
% input:
% x: time series data
% omega: angular frequency
% f: predicted step
% output:
% x_fit: fitting and predicting data
% reference:
% Zheng-Xin Wang, Qin Li, Ling-Ling Pei.
% Grey forecasting method of quarterly hydropower production in China based on a data grouping approach,
% Applied Mathematical Modelling,2017,51:302-316.
%% parameter setting
T=2*pi/omega; % periodic period
time=[1:length(x)]; 
p=f/T; % predicted step in each data group
for i=0:T-1
    index=time(mod(time,T)==i); % data index
    x_fit(:,i+1)=GM11(x(index),p); % establish grey model with each data group
end
x_fit=x_fit';
x_fit=x_fit(:);
end