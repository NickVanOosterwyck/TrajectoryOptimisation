%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% trap (1/3)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

trap = TrajOpt(input);
trap.optimizeTrajectory();

%% poly0
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 0.5;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly0 = TrajOpt(input);
poly0.optimizeTrajectory();

%% cheb2
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb2 = TrajOpt(input);
cheb2.optimizeTrajectory();


%% spline
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'spline';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;

spline2 = TrajOpt(input);
spline2.optimizeTrajectory();

%% plot solutions
fig = TrajPlot(input);
fig.addPlot(trap);
fig.addPlot(poly0);
fig.addPlot(cheb2);
fig.addPlot(spline2);
%fig.removeWhitespace();

%% plot objective functions
plotFitFun(cheb2)
plotFitFun(spline2)
plotFitFun(poly)
