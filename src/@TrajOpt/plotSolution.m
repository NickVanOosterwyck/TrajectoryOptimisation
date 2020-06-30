function [fig] = plotSolution(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% init
set(0,'DefaultTextInterpreter','latex'); 
set(0,'DefaultLegendInterpreter','latex'); 
set(0,'DefaultAxesTickLabelInterpreter','latex'); 

%% read input
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
nPieces = obj.input.nPieces;
breaks = obj.traj.breaks; % breakpoints
q =obj.res.q; % trajectory
Tm = obj.res.Tm; % driving torque

%% plot
syms t
fig = figure;
fig.Renderer = 'painters';
subplot(2,1,1);
xlabel('$t \, [s]$')
ylabel('$\theta(t) \, [rad]$')
xlim([timeA timeB])
hold on
for i=1:nPieces
    fplot(q(i),[breaks(i) breaks(i+1)],'LineWidth',2);
    p=subs(q(i),t,breaks(i));
    plot(breaks(i),p,'.k','MarkerSize',15);
end
p=subs(q(end),t,breaks(end));
plot(breaks(end),p,'.k','MarkerSize',15);

subplot(2,1,2);
xlabel('$t \, [s]$')
ylabel('$T_m(t) \, [Nm]$')
xlim([timeA timeB])
hold on
yline(0,'k','LineWidth',0.1,'HandleVisibility','off');
for i=1:nPieces
    fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',2);
    p=subs(Tm(i),t,breaks(i));
    plot(breaks(i),p,'.k','MarkerSize',15);
end
p=subs(Tm(end),t,breaks(end));
plot(breaks(end),p,'.k','MarkerSize',15);

end

