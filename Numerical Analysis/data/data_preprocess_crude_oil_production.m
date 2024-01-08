clc;
clear;
close all
%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 2);
% Specify sheet and range
opts.Sheet = "Fill in data";
opts.DataRange = "A2:B397";
% Specify column names and types
opts.VariableNames = ["date", "crudeoil"];
opts.VariableTypes = ["datetime", "double"];
% Specify variable properties
opts = setvaropts(opts, "date", "InputFormat", "");
% Import the data
tbl = readtable(".\crude oil production.xlsx", opts, "UseExcel", false);
% Convert to output type
date = tbl.date;
crudeoil = tbl.crudeoil;
% Clear temporary variables
clear opts tbl
%%
%% determine the Fourier order
train_data_length = 180;
train_data_index = [1:train_data_length]';
val_data_length = 108;
train_val_data_index = [1:train_data_length+val_data_length]';
test_data_length = 108;
train_test_data_index = [(length(crudeoil)-test_data_length-train_data_length)+1:length(crudeoil)]';
val_step = 12;
test_step = 12;
figure('unit','centimeters','position',[5,5,30,15],'PaperPosition',[5, 5, 30,15],'PaperSize',[30,15]);
plot(date,crudeoil,'-o','MarkerSize',2,'LineWidth',0.8)
rectangle('Position', [0, 800, 365.4*15, 1200],'FaceColor',[0.05 0.05 0.05 0.05]);
rectangle('Position', [365.4*15, 800, 365.4*9, 1200],'FaceColor',[0.9290 0.6940 0.1250 0.05]);
rectangle('Position', [365.4*24, 800, 365.4*9, 1200],'FaceColor',[.8500 0.3250 0.0980 0.10]);
xline(date(train_data_length+12+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*2+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*3+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*4+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*5+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*6+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*7+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*8+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*10+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*11+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*12+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*13+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*14+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*15+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*16+1),'--','HandleVisibility','off')
xline(date(train_data_length+12*17+1),'--','HandleVisibility','off')
% Create textbox
annotation(gcf,'textbox',...
    [0.27 0.83 0.15 0.05],...
    'String','training set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',14);
% Create textbox
annotation(gcf,'textbox',...
    [0.53 0.83 0.15 0.05],...
    'String','validation set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',14);
% Create textbox
annotation(gcf,'textbox',...
    [0.77 0.83 0.08 0.05],...
    'String','test set',...
    'LineStyle','none',...
    'FitBoxToText','off',...
    'FontName','Book Antiqua','FontSize',14);
set(gca,'FontName','Book Antiqua','FontSize',10); % 'YLim',ylim(i,:),
xlabel('Date','FontSize',12);
xtickformat('yyyy-MM')
ylabel({'crudeoil (10kt)'},'FontSize',14);
savefig(gcf,'..\figure\crude_oil.fig');
exportgraphics(gcf,'F:\博士\Nonlinear grey Fourier model\manuscript\figure\crude_oil.pdf')
% save
save('crudeoilproduction.mat','crudeoil','date')
writematrix(crudeoil,'D:\workspace\R\NGFM\data\crudeoilproduction.csv');
