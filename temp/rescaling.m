%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% create fitFun
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
input.isHornerNot = true;

mop = TrajOpt(input);
mop.defineFitness();

fitFun = mop.fit.fitFun;

%% get coeff
deg = polynomialDegree(fitFun);
[C, T] = coeffs(fitFun);
% maximum
[~,I_max] = max(abs(C));
C_max = vpa(C(I_max),4);
T_max = T(I_max);
% minimum
[~,I_min] = min(abs(C));
C_min = vpa(C(I_min),4);
T_min = T(I_min);

%% rescaling 2 DOF
syms p6t p7t p6 p7
p6_new = p6t/2^4;
p7_new = p7t/2^4;

fitFun = subs(fitFun,p6,p6_new);
fitFun = subs(fitFun,p7,p7_new);

%% rescaling 4 DOF
syms p6t p7t p8t p9t p6 p7 p8 p9
p6_new = p6t/2^5;
p7_new = p7t/2^5;
p8_new = p8t/2^5;
p9_new = p9t/2^5;

fitFun = subs(fitFun,p6,p6_new);
fitFun = subs(fitFun,p7,p7_new);
fitFun = subs(fitFun,p8,p8_new);
fitFun = subs(fitFun,p9,p9_new);

%% rescaling 4 DOF (spline)
syms th1 th2 th3 th4 z1 z2 z3 z4 th1t th2t th3t th4t z1t z2t z3t z4t
th1_new = th1t/2^5;
th2_new = th2t/2^5;
th3_new = th3t/2^5;
th4_new = th4t/2^5;
z1_new = z1t/2^5;
z2_new = z2t/2^5;
z3_new = z3t/2^5;
z4_new = z4t/2^5;

fitFun = subs(fitFun,p6,p6_new);
fitFun = subs(fitFun,p7,p7_new);
fitFun = subs(fitFun,p8,p8_new);
fitFun = subs(fitFun,p9,p9_new);

%% optimise (gloptipoly)
loadGloptipoly3
mpol p6t p7t
fitFun_char = ['fitFun_gl = ' char(vpa(fitFun))];
eval(fitFun_char)

lb = -2^4;
ub = 2^4;

K = [p6t>=lb, p6t<=ub, p7t>=lb, p7t<=ub];
P = msdp(min(fitFun_gl),K);
tic
[status,obj] = msol(P);
toc
double([p6t p7t])

%% optimise (gloptipoly)
loadGloptipoly3
mpol p6t p7t p8t p9t
fitFun_char = ['fitFun_gl = ' char(vpa(fitFun))];
eval(fitFun_char)

lb = -2^5;
ub = 2^5;

K = [p6t>=lb, p6t<=ub, p7t>=lb, p7t<=ub,...
     p8t>=lb, p8t<=ub, p9t>=lb, p9t<=ub];
P = msdp(min(fitFun_gl),K);
[status,obj] = msol(P);

%% optimise (gloptipoly) spline
loadGloptipoly3
mpol p6t p7t p8t p9t
fitFun_char = ['fitFun_gl = ' char(vpa(fitFun))];
eval(fitFun_char)

lb = 2^5;
ub = -2^5;

K = [p6t>=lb, p6t<=ub, p7t>=lb, p7t<=ub,...
     p8t>=lb, p8t<=ub, p9t>=lb, p9t<=ub];
P = msdp(min(fitFun_gl),K);
[status,obj] = msol(P);

%% optimise (intlab)
%loadIntlab
syms p6t p7t p8t p9t
DOF = mop.input.DOF;
designVar = mop.traj.var.designVar;

fitFun_vec = char(fitFun);
%old = arrayfun(@char, [p6t;p7t], 'uniform', false); %sym2cell
old = arrayfun(@char, [p6t;p7t;p8t;p9t], 'uniform', false); %sym2cell
new=cell(DOF,1);
for i=1:DOF
    new(i,1) = cellstr(['x(' num2str(i) ',:)']);
end
fitFun_vec = replace(fitFun_vec,old,new);
fitFun_vec = vectorize(fitFun_vec);
fitFun_vec = str2func(['@(x)' fitFun_vec]);

X0 = infsup(0.01*-2^5,0.01*2^5)*ones(DOF,1); % adapt
opt = verifyoptimset('NIT',1,'TolFun',0.001);

% solve
it=1;
fprintf(['Iteration: %d   Boxes left:%d    Time '...
    'elapsed: %4.2f s\n'],it,Inf,0)
tic
[ mu , X , XS , Data ] = verifyglobalmin(fitFun_vec,X0,opt);
%XS = collectList(XS,0.95);
while ~isempty(XS)
    it=it+1;
    fprintf(['Iteration: %d   Boxes left:%d    Time '...
        'elapsed: %4.2f s\n'],it,size(XS,2),toc)
    [ mu , X , XS , Data] = verifyglobalmin(Data,opt);
    XS = collectList(XS);
end
t_sol=toc;

% extract solution
designVar_sol=mid(X)';
fit_min=mid(mu)';

%% optimise (gradient)
X0=zeros(DOF,1);

options = optimoptions(@fminunc,'Display','final');

% optimize
tic
[X,fit_min,exitflag,output] = fminunc(fitFun_vec,X0,...
    options);
t_sol = toc;





