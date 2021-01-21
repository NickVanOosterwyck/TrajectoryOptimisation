% Comparison Optimised Trajectories Nedschroef
%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))
%loadGloptipoly3;

%% create fitFun
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

cheb7 = TrajOpt(input);

%% create dummy fitFun
% syms x1 x2
% fitFun = 4*x1^2+x1*x2-4*x2^2-2.1*x1^4+4*x2^4+x1^6/3;
% P = defipoly(['min' char(fitFun)],'x1,x2') % problem with symbolic toolbox

loadSedumi;
P{1,3} = -4; P{1,5} = 4; P{2,2} = 1;
P{3,1} = 4; P{5,1} = -2.1; P{7,1} = 1/3;
out = gloptipoly(P);

P{1}.c = [3 0;0 2;1 0];
P{1}.t = 'min';
P{2}.c = [0;1];
P{2}.t = '>=';
out = gloptipoly(P);

P(1,3) = -4; P(1,5) = 4; P(2,2) = 1;
P(3,1) = 4; P(5,1) = -2.1; P(7,1) = 1/3;
poly{1}.t = P;
poly{1}.t = 'min';
out = gloptipoly(poly);

P{1}.c = [0 -7 1; -12 0 0]; P{1}.t = 'min';
P{2}.c = [2 -1; 0 0; 0 0; 0 0; -2 0]; P{2}.t = '==';
P{3}.c = [0; -1]; P{3}.t = '<=';
P{4}.c = [-2; 1]; P{4}.t = '<=';
P{5}.c = [0 -1]; P{5}.t = '<=';
P{6}.c = [-3 1]; P{6}.t = '<=';
gloptipoly(P);


mpol x1 x2
fitFun = 4*x1^2+x1*x2-4*x2^2-2.1*x1^4+4*x2^4+x1^6/3;
P = msdp(min(fitFun));
[status,obj] = msol(P);

mpol x1 x2
nVar = 2;
nMon = 2;
cell{nvar,1}
var = {x1,x2};
pow = [2 1; 0 3];
coef = [3; 5];

pow = num2cell(pow);
coef = num2cell(coef);

sfit.var = var;
sfit.pow = pow;
sfit.coef = coef;

fitFun2 = mpol(sfit)

