% Optimised Trajectories Nedschroef Analysis
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

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
input.d_J = 5;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7 = TrajOpt(input);
cheb7.optimizeTrajectory();

%% spline5
% clear input
% required
% input.sMechanism = 'Nedschroef';
% input.sTrajType = 'spline';
% input.timeA = 0;
% input.timeB = 0.07375;
% input.posA = 0;
% input.posB = 3.0299;
% input.DOF = 2;
% input.sSolver = 'quasi-newton';
% 
% optional
% input.d_J = 4;
% input.d_Tl = 5;
% 
% spline5 = TrajOpt(input);
% spline5.optimizeTrajectory();

%% full plot objective functions (log)
cheb7.plotFitFun();
spline5.plotFitFun();

%% detailed plot cheb7 (lin)
cheb7.plotFitFun('lin',[-0.022 0.022]);
