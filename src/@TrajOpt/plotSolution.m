function [fig] = plotSolution(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% init
set(0,'DefaultTextInterpreter','latex'); 
set(0,'DefaultLegendInterpreter','latex'); 
set(0,'DefaultAxesTickLabelInterpreter','latex');

colorsUA = [0, 68, 102; 
    136, 017, 051; 
    187, 204, 204; 
    136, 153, 153; 
    051, 153, 204; 
    221, 153, 017; 
    170, 170 ,000]./255;

%% read input
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
nPieces = obj.input.nPieces;
q =obj.res.q; % trajectory
breaks = obj.res.breaks; % breakpoints
Tm = obj.res.Tm; % driving torque

%% plot
syms t
clr = 1;
fig = figure;
fig.Renderer = 'painters';
subplot(2,1,1);
xlabel('$t \, [s]$')
ylabel('$\theta(t) \, [rad]$')
xlim([timeA timeB])
hold on
for i=1:nPieces
    fplot(q(i),[breaks(i) breaks(i+1)],'LineWidth',2,...
        'Color',colorsUA(clr,:));
    br_q1=subs(q(i),t,breaks(i));
    br_q2=subs(q(i),t,breaks(i+1));
    plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k','MarkerSize',14);
end
subplot(2,1,2);
xlabel('$t \, [s]$')
ylabel('$T_m(t) \, [Nm]$')
xlim([timeA timeB])
hold on
yline(0,'k','LineWidth',0.1,'HandleVisibility','off');
for i=2:nPieces % add connecting lines (discontinous torque)
    br_Tm1=subs(Tm(i-1),t,breaks(i));
    br_Tm2=subs(Tm(i),t,breaks(i));
    plot([breaks(i) breaks(i)],[br_Tm1 br_Tm2],'LineWidth',2,...
        'Color',colorsUA(clr,:));
end
for i=1:nPieces
    fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',2,...
        'Color',colorsUA(clr,:));
    br_Tm1=subs(Tm(i),t,breaks(i));
    br_Tm2=subs(Tm(i),t,breaks(i+1));
    plot([breaks(i) breaks(i+1)],[br_Tm1 br_Tm2],'.k','MarkerSize',14);
end


end

