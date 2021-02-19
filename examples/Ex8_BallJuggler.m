%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% poly5
clear input
% required
input.sMechanism = 'BallJuggler';
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 0.5;
input.posA = 0;
input.posB = 90/180*pi;
input.isTimeResc = true;
input.isPosResc = true;

% optional
input.d_J = 4;
input.d_Tl = 4;

poly5 = TrajOpt(input);
poly5.defineProperties();

%% Convergence analysis
for d = 1:9
    input.d_J = d;
    poly5 = TrajOpt(input);
    poly5.defineProperties();
    L2_J(d) =poly5.prop.L2_J;
end
    


%%

poly5.optimizeTrajectory();