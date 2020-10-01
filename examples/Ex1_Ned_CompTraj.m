% Comparison Optimised Trajectories Nedschroef
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% trap (1/3)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

trap = TrajOpt(input);
trap.optimizeTrajectory();

%% poly5
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly5 = TrajOpt(input);
poly5.optimizeTrajectory();

%% cheb7
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7 = TrajOpt(input);
cheb7.optimizeTrajectory();

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

%% spline5
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'spline';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;

spline5 = TrajOpt(input);
spline5.optimizeTrajectory();

%% plot solutions
fig = TrajPlot();
fig.addPlot(trap);
fig.addPlot(poly5);
fig.addPlot(cheb7);
fig.addPlot(cheb9);
fig.addPlot(spline5);
%fig.removeWhitespace();

%% plot objective functions
cheb7.plotFitFun();
spline5.plotFitFun();
