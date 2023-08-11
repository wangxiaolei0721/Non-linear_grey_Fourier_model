function [ x_fit,par ] = DGFM( x,omega,order,f )
% DGFM function
% input:
% x: time series data
% omega: angular frequency
% order: Fourier order
% f: predicted step
% output:
% x_fit: fitting and predicting data
% par: estimated parameter
%% start
m=length(x);
ml=m-1;   % rows of estimate matrix H
xcum=cumsum(x);   % accumulative series
y=xcum(1:ml);
X=x(2:end);
one=ones(ml,1);
%% prepare data matrix
time=[2:m]';
times=repmat(time,1,order); % t
ome=omega*repmat([1:order],ml,1); % n*omega
cost=cos(ome.*times); % cos n*omega*t
sint=sin(ome.*times); % sin n*omega*t
cossint=zeros(ml,2*order);
for o=1:order
    cossint(:,2*o-1:2*o)=[cost(:,o),sint(:,o)];
end
%% estimate parameter
H=[y,time,one,cossint]; % prepare H
par=pinv(H'*H)*H'*X;
x_hat_fit=[x(1);H*par];
alpha=par(1);
c=par(2);
theta=par(3:end);
%% time sponse
y_m=xcum(end); % y(m)
x_hat_fore=zeros(f,1);
for l=1:f
    timel=repmat(m+l,1,order); % [m+1,m+1,...,m+1,m+1]
    omega_order=omega*[1:order]; % [omega,omega,...,N*omega,N*omega]
    sinl=sin(omega_order.*timel); % sin([omega,...,N*omega])
    cosl=cos(omega_order.*timel); % cos([omega,...,N*omega])
    cossinl=zeros(1,2*order);
    for j=1:order
        cossinl(:,2*j-1:2*j)=[cosl(:,j),sinl(:,j)];
    end
    x_hat_fore(l)=alpha*y_m+c*(m+l)+[1,cossinl]*theta; % x_hat(m+l)
    y_m=y_m+x_hat_fore(l); % y(m+l)=y(m+l-1)+x_hat(m+l)
end
x_fit=[x_hat_fit;x_hat_fore];
end