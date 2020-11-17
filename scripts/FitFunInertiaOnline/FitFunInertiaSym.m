%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..\..']))

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
input.isPosResc = true;
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

% save new vectorized function
save([fileparts(matlab.desktop.editor.getActiveFilename) ...
    '\fitFun_vec.mat'],'fitFun_vec')

%% check & plot
% check
a_J_sol = [0.012438014347721;6.097620376184698e-05;-0.017573048370808;6.302708402890077e-05;0.008885823771286];
%a_J_sol = [0.012438014347721;-3.915888336773353e-05;-0.017573048370808;5.297875506136531e-04;0.008885823771286;-4.196018430545512e-04];
%a_J_sol = [0.012445244055890;-3.915888336772541e-05;-0.017724698134493;5.297875506136194e-04;0.009340251136910;-4.196018430545183e-04;-3.328642814668063e-04];
sqrt(fitFun_vec([0;0],a_J_sol)) % must be 22.4736

%plot
syms a0 a1 a2 a3 a4 a5 a6

fitFun = cheb2.fit.fitFun;

fitFun = subs(fitFun,a0,(a_J_sol(1)));
fitFun = subs(fitFun,a1,(a_J_sol(2)));
fitFun = subs(fitFun,a2,(a_J_sol(3)));
fitFun = subs(fitFun,a3,(a_J_sol(4)));
fitFun = subs(fitFun,a4,(a_J_sol(5)));
%fitFun = subs(fitFun,a5,(a_J_sol(6)));
%fitFun = subs(fitFun,a6,(a_J_sol(7)));

figure
h=fsurf(log10(fitFun),[-1,1],'ShowContours','on');
h.EdgeColor = 'none';

%% optimise
fitFun2 = @(x)fitFun_vec(x,a_J_sol);

X0=zeros(2,1);
[p] = fminunc(fitFun2,X0);

p6 = p(1)
p7 = p(2)

