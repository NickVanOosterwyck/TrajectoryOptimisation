%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% settings
time = 0.11;
speed = 1400;
startangle = 0;
endangle = 90;

%% cvel
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'cvel';
input.timeA = 0;
input.timeB = time;
input.posA = startangle/180*pi;
input.posB = endangle/180*pi;
input.speedB = speed/180*pi;

% optional
input.d_J = 4;
input.d_Tl = 4;

cvel = TrajOpt(input);
cvel.optimizeTrajectory();

%% poly5
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = time;
input.posA = startangle/180*pi;
input.posB = endangle/180*pi;
input.speedB = speed/180*pi;

% optional
input.d_J = 4;
input.d_Tl = 4;
input.isTimeResc = true;
input.isPosResc = true;

poly5 = TrajOpt(input);
poly5.optimizeTrajectory();

fig = TrajPlot();
fig.addPlot(poly5);

%% cheb7
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = time;
input.posA = startangle/180*pi;
input.posB = endangle/180*pi;
input.speedB = speed/180*pi;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 4;
input.isTimeResc = true;
input.isPosResc = true;

cheb7 = TrajOpt(input);
cheb7.optimizeTrajectory();

fig = TrajPlot();
fig.addPlot(cheb7);

%% cheb9
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = time;
input.posA = startangle/180*pi;
input.posB = endangle/180*pi;
input.speedB = speed/180*pi;
input.DOF = 4;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 4;
input.isTimeResc = true;
input.isPosResc = true;

cheb9 = TrajOpt(input);
cheb9.optimizeTrajectory();

%% plot solutions
fig = TrajPlot();
fig.addPlot(cvel);
% fig.addPlot(poly5);
fig.addPlot(cheb7);
% fig.addPlot(cheb9);
%fig.addRpmAxis();

%% Convergence analysis
for d = 1:9
    input.d_J = d;
    input.d_Tl = d;
    poly5 = TrajOpt(input);
    poly5.defineProperties();
    L2_J(d) = poly5.prop.L2_J;
    L2_Tl(d) = poly5.prop.L2_Tl;
end

figure
subplot(2,1,1)
plot(1:9,L2_J(1:9))
subplot(2,1,2)
plot(1:9,L2_Tl(1:9))

% plot result
% optional
input.d_J = 4;
input.d_Tl = 4;

poly5 = TrajOpt(input);
poly5.defineProperties();

figure
subplot(2,1,1)
hold on
fplot(poly5.prop.J,[0 105.5/180*pi])
plot(poly5.prop.J_dis(:,1),poly5.prop.J_dis(:,2),'.')
subplot(2,1,2)
hold on
fplot(poly5.prop.Tl,[0 1.5708])
plot(poly5.prop.Tl_dis(:,1),poly5.prop.Tl_dis(:,2),'.')
   
