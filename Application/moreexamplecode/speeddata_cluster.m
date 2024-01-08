clc;
clear;
close all;
tic
% load data
load roadhour.mat
roadhour = roadhour';
% k-medoids Clustering
rng(0) % For reproducibility
[idx,c,sumd,d] = kmedoids(roadhour,4,'Distance',@dtwf,'Replicates',3,'Options',statset('Display','iter'));
% cluster indices
cluster1=find(idx==1);
cluster2=find(idx==2);
cluster3=find(idx==3);
cluster4=find(idx==4);
toc
function dist = dtwf(x,y)
% n = numel(x);
m2 = size(y,1);
dist = zeros(m2,1);
for i=1:m2
    dist(i) = dtw(x,y(i,:));
end
end