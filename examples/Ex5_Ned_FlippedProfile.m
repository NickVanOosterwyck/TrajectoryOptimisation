% Nedschroef Comparison with flipped motion profiles
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% cheb7 forward
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.075;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7For = TrajOpt(input);
cheb7For.optimizeTrajectory();

%% cheb7 backward
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.075;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7Back = TrajOpt(input);
cheb7Back.optimizeTrajectory();

%% cheb7 flipped
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'custom';
input.timeA = 0;
input.timeB = 0.075;
input.posA = 3.0299;
input.posB = 0;
syms t x
input.trajFun = subs(cheb7For.res.q,t,-(x-0.075)); % flip profile
input.trajFunBreaks = [0 0.07375]; 

% optional
input.d_J = 4;
input.d_Tl = 5;

cheb7Flip = TrajOpt(input);
cheb7Flip.optimizeTrajectory();

%% plot
fig = TrajPlot('northeast');
fig.addPlot(cheb7Back,'Regular');
fig.addPlot(cheb7Flip,'Flipped');
fig.addRpmAxis();
%fig.removeWhitespace(); % after rescale


