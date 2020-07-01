%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% trap (1/3)
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
%input.isTimeResc = true;
%input.isPosResc = true;

trap = TrajOpt(input);
trap.optimizeTrajectory();

%% poly5
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'polyref';
input.timeA = 0;
input.timeB = 0.0738;
input.posA = 0;
input.posB = 3.0299;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;

poly0 = TrajOpt(input);
poly0.optimizeTrajectory();

%% cheb2
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


fig = TrajPlot(input);
fig.addPlot(trap);
fig.removeWhitespace();

% traj = Ned.defineTrajectory();
% prop = Ned.defineProperties();
% fit = Ned.defineFitness();


