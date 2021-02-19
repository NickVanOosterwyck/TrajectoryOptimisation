% Optimised Trajectories Nedschroef Analysis
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% poly5
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.isTimeResc = true;
input.isPosResc = true;

% optional
input.d_J = 6;
input.d_Tl = 5;

poly5 = TrajOpt(input);
poly5.optimizeTrajectory();

%% cheb9
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 4;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb9 = TrajOpt(input);
cheb9.optimizeTrajectory();

%% plot solutions
fig = TrajPlot();
fig.addPlot(poly5,'standard');
fig.addPlot(cheb9,'optimized');
fig.f.Position(3:4)=[747 420];

%% compare acceleration with inertia
syms t ph
tdis = poly5.res.DIS.t;
pos_poly5 = subs(poly5.res.q,t,tdis)./pi.*180;
acc_poly5 = subs(poly5.res.qd2,t,tdis);
pos_cheb9 = subs(cheb9.res.q,t,tdis)./pi.*180;
acc_cheb9 = subs(cheb9.res.qd2,t,tdis);

colorMap = [0, 68, 102;
    136, 017, 051;
    051, 153, 204;
    221, 153, 017;
    170, 170 ,000
    187, 204, 204;]./255;
fig = figure;
fig.Position(3:4)=[747 420];
hold on
yyaxis left
xlabel('$\theta \, [^{\circ}]$')
ylabel('$\ddot{\theta} \, [^{\circ}/s^2]$')
xlim([-5 180])
plot(pos_poly5,acc_poly5,'-','LineWidth',1.2,'Color',colorMap(1,:))
plot(pos_cheb9,acc_cheb9,':','LineWidth',1.2,'Color',colorMap(1,:))
legend('standard','optimized')

yyaxis right
ylabel('$J \, [kgm^2]$')
pos_J = rescale(poly5.prop.J_dis(:,1),0,3.0299/pi*180);
J = poly5.prop.J_dis(:,2);
plot(pos_J,J,'LineWidth',1.2,'Color',colorMap(2,:),'HandleVisibility','off')

ax = gca;
ax.YAxis(1).Color = colorMap(1,:);
ax.YAxis(1).LineWidth = 1.2;
ax.YAxis(2).Color = colorMap(2,:);
ax.YAxis(2).LineWidth = 1.2;

%% compare speed with inertiavariation
speed_poly5 = subs(poly5.res.qd1,t,tdis).^2;
speed_cheb9 = subs(cheb9.res.qd1,t,tdis).^2;

fig = figure;
fig.Position(3:4)=[747 420];
hold on
yyaxis left
xlabel('$\theta \, [^{\circ}]$')
ylabel('${\dot{\theta}}^2 \, [^{\circ^2}/s^2]$')
xlim([-5 180])
plot(pos_poly5,speed_poly5,'-','LineWidth',1.2,'Color',colorMap(1,:))
plot(pos_cheb9,speed_cheb9,':','LineWidth',1.2,'Color',colorMap(1,:))
legend('standard','optimized')

yyaxis right
ylabel('$\mathrm{d}J/\mathrm{d}\theta \, [kgm^2/^{\circ}]$')
Jd1 = [eps; diff(J)./diff(pos_J)];
plot(pos_J,Jd1,'LineWidth',1.2,'Color',colorMap(2,:),'HandleVisibility','off')

ax = gca;
ax.YAxis(1).Color = colorMap(1,:);
ax.YAxis(1).LineWidth = 1.2;
ax.YAxis(2).Color = colorMap(2,:);
ax.YAxis(2).LineWidth = 1.2;


%% compare different parts of torque equation
fig = figure;
fig.Position(3:4)=[747 420];
subplot(2,1,1)
hold on
xlabel('$t \, [s]$')
ylabel('$T \, [Nm]$')
ylim([-40 40])
title('Standard')
fplot(poly5.res.Tm,[0 0.07375],'LineWidth',2,'Color',colorMap(1,:))
fplot(poly5.res.TE.Tload,[0 0.07375],'LineWidth',1.2,'Color',colorMap(2,:))
fplot(poly5.res.TE.Tvar,[0 0.07375],'LineWidth',1.2,'Color',colorMap(3,:))
fplot(poly5.res.TE.Tacc,[0 0.07375],'LineWidth',1.2,'Color',colorMap(4,:))
legend('$T_m$','$T_l$','$T_{var}$','$T_{acc}$')

subplot(2,1,2)
hold on
xlabel('$t \, [s]$')
ylabel('$T \, [Nm]$')
ylim([-40 40])
title('Optimized')
fplot(cheb9.res.Tm,[0 0.07375],'LineWidth',2,'Color',colorMap(1,:))
fplot(cheb9.res.TE.Tload,[0 0.07375],'LineWidth',1.2,'Color',colorMap(2,:))
fplot(cheb9.res.TE.Tvar,[0 0.07375],'LineWidth',1.2,'Color',colorMap(3,:))
fplot(cheb9.res.TE.Tacc,[0 0.07375],'LineWidth',1.2,'Color',colorMap(4,:))
legend('$T_m$','$T_l$','$T_{var}$','$T_{acc}$')
