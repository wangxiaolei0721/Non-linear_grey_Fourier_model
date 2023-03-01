function  x_fit = GM11_Gurcan( x,omega,f )
% grey model with sine and cosine
% input:
% x: time series data
% omega: angular frequency
% f: predicted step
% output:
% x_fit: fitting and predicting data
% reference:
% Gurcan Comert, Negash Begashaw, Nathan Huynh.
% Improved grey system models for predicting traffic parameters,
% Expert Systems with Applications,2021,177:114972.
%% start
l=length(x);
x1=cumsum(x);  % accumulative series
z1=(x1(2:end)+x1(1:end-1))/2; % neighbor mean series
omegal=omega*[2:l]';
%% estimate parameter
B=[-z1,sin(omegal),cos(omegal),ones(l-1,1)];
Y=x(2:end);
par=pinv(B'*B)*B'*Y;
alpha=par(1);
b1=par(2);
b2=par(3);
b3=par(4);
constant=b3/alpha;
cos_cor=(alpha*b2-b1*omega)/(alpha^2+omega^2);
sin_cor=(alpha*b1+b2*omega)/(alpha^2+omega^2);
%% initial value
t0=1;
sint0=sin(omega*t0);
cost0=cos(omega*t0);
C0=x(1)-constant-cos_cor*cost0-sin_cor*sint0;
C=exp(alpha*t0)*C0;
%% time sponse function
for t=1:l+f
    x1_fit(t,1)=C*exp(-alpha*t)+cos_cor*cos(omega*t)+sin_cor*sin(omega*t);
end
x_fit=[NaN;diff(x1_fit)];
end