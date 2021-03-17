% Comparison Optimised Trajectories Nedschroef
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% trapref
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0;
input.timeB = 0.07375;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

trapref = TrajOpt(input);
trapref.optimizeTrajectory();

%% trap
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'trap';
input.timeA = 0;
input.timeB = 0.05213;
input.posA = 0;
input.posB = 3.0299;

% optional
input.d_J = 4;
input.d_Tl = 5;

trap = TrajOpt(input);
trap.optimizeTrajectory();


%% cheb7
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'cheb';
input.timeA = 0;
input.timeB = 0.03871;
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

%%
time = linspace(0.07375,0.035,7);
n = length(time);
Trms = zeros(0,n);
Tmax = zeros(0,n);

Tlim = 76.1;

for i = 1:n
    input.timeB = time(i);
    mop = TrajOpt(input);
    mop.optimizeTrajectory();
    Trms(i) = mop.res.Trms_dis;
    Tmax(i) = mop.res.Tmax_dis;
end

%%
figure
plot(time,Tmax)

