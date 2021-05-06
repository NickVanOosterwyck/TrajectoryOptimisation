%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% create position profile
nPieces = 1;
p0i= sym('p0%d',[1 nPieces]).';
symVar = sym('p%d%d',[5 nPieces]).';
symVar = [p0i symVar];

syms x
pol=x.^(0:5).';
q=symVar*pol;
qd1=diff(q);
qd2=diff(qd1);

%% set constraints
constrVar=sym('c%d%d', [3 nPieces+1]);
breaks = linspace(-1,1,nPieces+1);
syms pA pB tA tB
constrVar = [pA;0;0;pB;0;0];
breaks = [tA tB];
for i= 1:nPieces
    constrEq_bnd = sym.empty(6,0);
    constrEq_bnd(1,1) = subs(q(i),x,breaks(i))==constrVar(1,i);
    constrEq_bnd(2,1) = subs(qd1(i),x,breaks(i))==constrVar(2,i);
    constrEq_bnd(3,1) = subs(qd2(i),x,breaks(i))==constrVar(3,i);
    constrEq_bnd(4,1) = subs(q(i),x,breaks(i+1))==constrVar(1,i+1);
    constrEq_bnd(5,1) = subs(qd1(i),x,breaks(i+1))==constrVar(2,i+1);
    constrEq_bnd(6,1) = subs(qd2(i),x,breaks(i+1))==constrVar(3,i+1);
    sol = solve(constrEq_bnd,symVar(i,:));
    constrVar_sol=struct2array(sol);
    q(i) = subs(q(i),symVar(i,:),constrVar_sol);
    qd1(i) = subs(q(i),symVar(i,:),constrVar_sol);
    qd2(i) = subs(q(i),symVar(i,:),constrVar_sol);
end



%% properties
syms th
b_J = [0.012438014347721,6.097620376184698e-05,-0.017573048370808,...
    6.302708402890077e-05,0.008885823771286];
J = b_J*(th.^(0:4).');
Jd1 = diff(J,th);

%% torque equation
Ji = subs(J,th,q);
Jd1i = subs(Jd1,th,q);
Tm = Ji.*qd2 + 1/2*Jd1i.*qd1.^2;

tic
fitFun=sym(zeros(nPieces,1));
for i=1:nPieces
    %Tm = simplify(Tm);
    fitFun(i,1)=int(Tm(i).^2,x,breaks(i),breaks(i+1));
    %fitFun = simplify(fitFun);
end
fitFun = ones(1,nPieces)*fitFun;
toc


%%
fitFun_char = latex(vpa(fitFun,4));
fileID = fopen('fitFun.txt','w');
fprintf(fileID,'%s',fitFun_char);
fclose(fileID);

