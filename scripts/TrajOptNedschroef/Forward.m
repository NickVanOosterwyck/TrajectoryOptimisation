%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..\..']))

%% forward
%% trapF (1/3)
clear input
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

trapF = TrajOpt(input);
trapF.optimizeTrajectory();

%% poly5F (reference)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly5F = TrajOpt(input);
poly5F.optimizeTrajectory();

%% cheb7F
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

cheb7F = TrajOpt(input);
cheb7F.optimizeTrajectory();

%% cheb9F
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

cheb9F = TrajOpt(input);
cheb9F.optimizeTrajectory();

%% cheb13F
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;
input.DOF = 8;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb13F = TrajOpt(input);
cheb13F.optimizeTrajectory();

%% backward
%% trapB (1/3)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;

% optional
input.d_J = 4;
input.d_Tl = 5;

trapB = TrajOpt(input);
trapB.optimizeTrajectory();

%% poly5B (reference)
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly5';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;

% optional
input.d_J = 4;
input.d_Tl = 5;

poly5B = TrajOpt(input);
poly5B.optimizeTrajectory();

%% cheb7B
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 2;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb7B = TrajOpt(input);
cheb7B.optimizeTrajectory();

%% cheb9B
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

cheb9B = TrajOpt(input);
cheb9B.optimizeTrajectory();

%% cheb13B
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0.1675;
input.timeB = 0.2250;
input.posA = 3.0299;
input.posB = 0;
input.DOF = 8;
input.sSolver = 'quasi-newton';

% optional
input.d_J = 4;
input.d_Tl = 5;
input.isTimeResc = true;
input.isPosResc = true;

cheb13B = TrajOpt(input);
cheb13B.optimizeTrajectory();

%% plot
fig = TrajPlot(input);
fig.addPlot(trapF);
fig.addPlot(trapB);
fig.addPlot(poly5F);
fig.addPlot(poly5B);
fig.addPlot(cheb7F);
fig.addPlot(cheb7B);
fig.addPlot(cheb9F);
fig.addPlot(cheb9B);
fig.addPlot(cheb13F);
fig.addPlot(cheb13B);
%fig.removeWhitespace();

