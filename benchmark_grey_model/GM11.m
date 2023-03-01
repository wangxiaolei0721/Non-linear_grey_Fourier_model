function  x_fit  = GM11( x,f )
% grey model
% input:
% x: time series data
% f: predicted step 
% output:
% x_fit: fitting and predicting data
% reference:
% Liu Sifeng, Yang Yingjie, Jeffrey Forrest.
% Grey Data Analysis: methods, models and applications,
% Singapore: Springer, 2017.
%% start
l=length(x);
x1=cumsum(x);  % accumulative series
z1=(x1(2:end)+x1(1:end-1))/2; % neighbor mean series
%% estimate parameter
B=[-z1,ones(l-1,1)];
Y=x(2:end);
p=(B'*B)\B'*Y;
a=p(1);
b=p(2);
%% time sponse function
k=[1:l+f]';
xs=(x(1)-b/a)*exp(-a*(k-1))+b/a;
x_fit=[NaN;diff(xs)];
end