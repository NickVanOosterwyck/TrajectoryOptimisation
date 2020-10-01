% Nedschroef Forward and Backward Motion
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% Forward
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

%% Pause1
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'pause';
input.timeA = 0.07375;
input.timeB = 0.1;
input.posA = 3.0299;
input.posB = 3.0299;

pause1 = TrajOpt(input);
pause1.optimizeTrajectory();

%% combine
total  = [cheb7 pause1];

%% plot
fig = TrajPlot(input);
fig.addPlot(total);