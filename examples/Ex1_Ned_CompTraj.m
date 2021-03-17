% Comparison Optimised Trajectories Nedschroef
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% trap13
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

trap13 = TrajOpt(input);
trap13.optimizeTrajectory();

%% poly5
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.isTimeResc = true;
input.isPosResc = true;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly5 = TrajOpt(input);
poly5.optimizeTrajectory();

%% poly7J0
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.isJerk0 = true;
input.isTimeResc = true;
input.isPosResc = true;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly7J0 = TrajOpt(input);
poly7J0.optimizeTrajectory();

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

%% cheb9J0
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.isJerk0 = true;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb9J0 = TrajOpt(input);
cheb9J0.optimizeTrajectory();

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

%% poly17GA
load('poly17GA.mat');
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'dis';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.time = poly17GA_data(:,1);
input.traj = poly17GA_data(:,2);

% optional
input.d_J = 4;
input.d_Tl = 5;

poly17GA = TrajOpt(input);
poly17GA.optimizeTrajectory();

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
fig.addPlot(trap13);
fig.addPlot(poly5);
fig.addPlot(poly7J0);
fig.addPlot(cheb7);
fig.addPlot(cheb9J0);
fig.addPlot(cheb9);
fig.addPlot(poly17GA,'poly17GA');
%fig.addPlot(spline5);
fig.addRpmAxis();
fig.removeWhitespace(); % repeat after rescale
