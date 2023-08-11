function mae = minobject(parameter,road_train_val, omega,orderi,train,val)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
gamma = parameter.gamma;
% gamma 核参数
sigma = parameter.sigma;
%
road_length=length(road_train_val);
road_val_all=[];
road_pre_all=[];
k=1; % Mark the first position of the data to be calculated
% while the last used data less than the data length
while (k+train+val-1)<=road_length
    % train data
    road_train=road_train_val(k:k+train-1);
    % validation data
    road_val=road_train_val(k+train:k+train+val-1);
    % all validation data
    road_val_all=[road_val_all;road_val];
    % call model code
    road_fit_pre = NGFM(road_train,omega,orderi,gamma,sigma,val);
    % predictive data
    road_pre=road_fit_pre(train+1:end);
    % all predictive data
    road_pre_all=[road_pre_all;road_pre];
    % location update
    k=k+val;
end
mae=mean(abs(road_pre_all-road_val_all));
end

