function [ x_fit,par ] = GFM_linear_integral( x,omega,order,f )
% GFM_linear_integral function
% input:
% x: time series data
% omega: angular frequency
% order: Fourier order
% f: predicted step
% output:
% x_fit: fitting and predicting data
% par: estimated parameter
%% start
l=length(x);
time=[1:l]';
t1=time(1);
m=l-1;   % rows of estimate matrix H
x_cum=1/2*cumsum(x(1:end-1,1))+1/2*cumsum(x(2:end,1));   % accumulative series
X=x(2:end,1); %  X
one=ones(m,1);
time_t1=time(2:end)-t1;
times=repmat(time(2:end),1,order); % t
t1_m=repmat(t1,m,order); % t1
ome=omega*repmat([1:order],m,1); % n*omega
sint=sin(times.*ome); % sin n*omega*t
sint1=sin(t1_m.*ome); % sin n*omega*t0
cost=cos(times.*ome); % cos n*omega*t
cost1=cos(t1_m.*ome);  % cos n*omega*t0
sintnw=(sint-sint1)./ome;
costnw=-(cost-cost1)./ome;
sincostnw=zeros(m,2*order);
for i=1:order
    sincostnw(:,2*i-1:2*i)=[sintnw(:,i),costnw(:,i)];
end
%% estimate parameter
H=[x_cum,one,time_t1,sincostnw]; % prepare H
par=pinv(H'*H)*H'*X;
alpha=par(1);
eta=par(2);
Theta=par(3:end);
T=zeros(2*order+1,2*order+1); % convert matrix T
T(1,1)=-alpha;
for i=1:order
    T(2*i:2*i+1,2*i:2*i+1)=[-alpha,i*omega;-i*omega,-alpha];
end
theta=T\Theta;
%% initial value
timet1=repmat(t1,1,order);
omega_order=omega*[1:order];
sint1=sin(omega_order.*timet1);
cost1=cos(omega_order.*timet1);
cossint1=zeros(1,2*order);
for i=1:order
    cossint1(:,2*i-1:2*i)=[cost1(:,i),sint1(:,i)];
end
c0=eta-[1,cossint1]*theta;
c_hat=exp(-alpha*t1)*c0;
%% time sponse
one=ones(l+f,1);
time=[1:l+f]'; % new t
times=repmat(time,1,order); % t
ome=omega*repmat([1:order],l+f,1); % n*omega
sint=sin(times.*ome); % sin n*omega*t
cost=cos(times.*ome); % cos n*omega*t
cossint=zeros(l+f,2*order);
for i=1:order
    cossint(:,2*i-1:2*i)=[cost(:,i),sint(:,i)];
end
expt=c_hat*exp(alpha*time);
trit=[one,cossint]*theta;
x_fit=expt+trit;
end