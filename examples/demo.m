%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% Nedschroef
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

Ned = TrajOpt(input);
Ned.optimizeTrajectory();

% traj = Ned.defineTrajectory();
% prop = Ned.defineProperties();
% fit = Ned.defineFitness();


