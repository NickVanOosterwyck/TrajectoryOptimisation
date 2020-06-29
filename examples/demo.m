%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

% Nedschroef
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;
input.d_J = 4;
input.d_Tl = 5;
input.DOF = 2;
input.sSolver = 'quasi-newton';

Ned = TrajOpt(input);

% traj = Ned.defineTrajectory();
% prop = Ned.defineProperties();
% fit = Ned.defineFitness();

Ned.optimizeTrajectory();