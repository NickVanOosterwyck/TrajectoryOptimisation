%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%%
clear input
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
input.sFitNot = 'vpa';
input.digits = 10;
input.isJSym = true;

cheb2=TrajOpt(input);
cheb2.defineTrajectory();
cheb2.defineProperties();
cheb2.defineFitness();

%% create fitnessfunction 
fitFun = cheb2.fit.fitFun;
digits = cheb2.input.digits;
designVar = cheb2.traj.var.designVar;
DOF = cheb2.input.DOF;
a_J = cheb2.prop.a_J;
sFitNot = cheb2.input.sFitNot;
d_J = cheb2.input.d_J;

switch sFitNot
    case 'frac'
        fitFun_vec = char(fitFun);
    case 'vpa'
        fitFun_vec = char(vpa(fitFun,digits));
end

% replace trajectory parameters
old = arrayfun(@char, designVar, 'uniform', false);
new=cell(DOF,1);
for i=1:DOF
    new(i,1) = cellstr(['x(' num2str(i) ',:)']);
end
fitFun_vec = replace(fitFun_vec,old,new);

% replace inertia parameters
old = arrayfun(@char, a_J.', 'uniform', false);
new=cell(d_J+1,1);
for i=1:d_J+1
    new(i,1) = cellstr(['a(' num2str(i) ')']);
end
fitFun_vec = replace(fitFun_vec,old,new);

fitFun_vec = vectorize(fitFun_vec);
fitFun_vec = str2func(['@(x,a)' fitFun_vec]);
t_vec=toc;

% check
a_J_sol = [0.0036267865;-0.0000971262;0.0154910117;-0.0102045912;0.0016869776];
sqrt(fitFun_vec([0;0],a_J_sol)) % must be 22.4736

% save new vectorized function
save([fileparts(matlab.desktop.editor.getActiveFilename) ...
 '\fitFun_vec.mat'],'fitFun_vec')
