function [ x_fit_pre,par ] = NGFM( x,omega,order,gamma,sigma,test )
% nonlinear grey Fourier model
% input:
% x: time series data
% omega: angular frequency
% order: Fourier order
% gamma: a hyper-parameter used to adjust the weight between the fitting errors and flatness
% sigma: kernel parameter
% test: predicted step
% output:
% x_fit_pre: fitting and predicting data
% par: estimated parameter
%% start
m=length(x)-1;   % rows of estimate matrix H
xcum=cumsum(x);   % accumulative series
y=xcum(1:m);
X=x(2:end);
%% prepare data matrix
one=ones(m,1);
time=[2:length(x)]';
times=repmat(time,1,order); % K
ome=omega*repmat([1:order],m,1); % n*omega
costimes=cos(ome.*times); % cos n*omega*k
sintimes=sin(ome.*times); % sin n*omega*k
Phi=zeros(m);
for i = 1:m
    for j = 1:m
        Phi(i,j) = GussianKernel(y(i),y(j),sigma);
    end
end
I=eye(m);
bigmatrix=zeros(m+2*order+1);
bigmatrix(1,1:m)=one';
bigmatrix(2:(1+order),1:m)=costimes';
bigmatrix((2+order):(1+2*order),1:m)=sintimes';
bigmatrix((2+2*order):end,1:m)=Phi+I/gamma;
bigmatrix((2+2*order):end,m+1)=one;
bigmatrix((2+2*order):end,(m+2):(m+order+1))=costimes;
bigmatrix((2+2*order):end,(m+order+2:end))=sintimes;
bigy=[zeros(2*order+1,1);X];
%% estimate parameter
% cond(bigmatrix)
par=bigmatrix\bigy;
alpha=par(1:m);
A_0=par(m+1);
A1AN=par((m+2):(m+1+order));
B1BN=par((m+order+2):end);
%% time sponse
x_fit=Phi*alpha+A_0+costimes*A1AN+sintimes*B1BN;
x_fit=[x(1);x_fit];
y_end=xcum(length(x));
Phit=zeros(1,m);
for k=1:test
    timet=length(x)+k;
    omega_order=omega*[1:order]; % [omega,...,N*omega]
    cost=cos(omega_order.*timet); % cos([omega,...,N*omega])
    sint=sin(omega_order.*timet); % sin([omega,...,N*omega])
    for j = 1:m
        Phit(j) = GussianKernel(y(j),y_end,sigma);
    end
    x_pre(k,1)=Phit*alpha+A_0+cost*A1AN+sint*B1BN;
    y_end=y_end+x_pre(k,1); % y(m+l)=y(m+l-1)+x_pre(m+l)
end
x_fit_pre=[x_fit;x_pre];
end
% Gussian kernel function
function y = GussianKernel(x,y,sigma)
% Gussian Kernel function
% input: u, v, and kernel parameter sigma
% output: y

xy = norm(x-y)^2;
sigma2 = 2*power(sigma,2);
y = exp(-xy/sigma2);
end