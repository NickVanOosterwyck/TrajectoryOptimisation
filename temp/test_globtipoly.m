% Comparison Optimised Trajectories Nedschroef
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))
loadGloptipoly3;

%% fitFun
syms x1 x2
fitFun = 4*x1^2+x1*x2-4*x2^2-2.1*x1^4+4*x2^4+x1^6/3;

%% globtipoly3 (unconstrained)
mpol x1 x2
fitFun_char = ['fitFun_gl = ' char(vpa(fitFun))];
eval(fitFun_char)

P = msdp(min(fitFun_gl));
[status,obj] = msol(P);

%% globtipoly3 (constrained)
mpol x1 x2
fitFun_char = ['fitFun_gl = ' char(vpa(fitFun))];
eval(fitFun_char)

lb = -8;
ub = 8;
K = [p6>=lb, p6<=ub, p7>=lb, p7<=ub];

P = msdp(min(fitFun_gl));
[status,obj] = msol(P);





