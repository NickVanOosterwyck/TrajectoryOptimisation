% Nedschroef Comparison with GA AmoCAD
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% cheb9
%%% cheb9For
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

cheb9For = TrajOpt(input);
cheb9For.optimizeTrajectory();

%%% pause1
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'pause';
input.timeA = 0.07375;
input.timeB = 0.1675;
input.posA = 3.0299;
input.posB = 3.0299;

pause1 = TrajOpt(input);
pause1.optimizeTrajectory();

%%% cheb9 backwards
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 4;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb9Bac = TrajOpt(input);
cheb9Bac.optimizeTrajectory();

%%% pause2
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'pause';
input.timeA = 0.2250;
input.timeB = 0.3;
input.posA = 0;
input.posB = 0;

pause2 = TrajOpt(input);
pause2.optimizeTrajectory()

%%% combine
cheb9  = [cheb9For pause1 cheb9Bac pause2];

%% poly17GA
load('poly17GA.mat');
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'dis';
input.timeA = 0;
input.timeB = 0.3;
input.posA = 0;
input.posB = 3.0299;
input.time = poly17GA_data(:,1);
input.traj = poly17GA_data(:,2);

% optional
input.d_J = 4;
input.d_Tl = 5;

poly17GA = TrajOpt(input);
poly17GA.optimizeTrajectory();

%% plot
fig = TrajPlot('northeast');
fig.addPlot(cheb9);
fig.addPlot(poly17GA,'poly17GA');
