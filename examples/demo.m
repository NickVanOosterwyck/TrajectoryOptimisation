%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% Nedschroef
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 0;
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

% traj = Ned.defineTrajectory();
% prop = Ned.defineProperties();
% fit = Ned.defineFitness();


