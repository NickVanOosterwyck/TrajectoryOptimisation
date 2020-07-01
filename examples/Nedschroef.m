%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% trapezoidal (1/3)
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
%input.isTimeResc = true;
%input.isPosResc = true;

Ned = TrajOpt(input);
Ned.optimizeTrajectory();

fig = TrajPlot(input);
fig.addPlot(Ned);
fig.removeWhitespace();

% traj = Ned.defineTrajectory();
% prop = Ned.defineProperties();
% fit = Ned.defineFitness();


