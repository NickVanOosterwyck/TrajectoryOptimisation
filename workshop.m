%% input
syms pA pB
posLB = pA;
posUB = pB;
timeLB = -1;
timeUB = 1;
speedLB = 0;
speedUB = 0;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. polynomial motion profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 4; % degree
isJerk0 = 0; % jerk constraint

%% 1.a create equations for position, speed, acceleration and jerk
syms p_0
if isJerk0
    symVar=sym('p_', [1 7+DOF]);
else
    symVar=sym('p_', [1 5+DOF]);
end
symVar=[p_0 symVar];
syms x
pol=x.^(0:9).';
q=symVar*pol;
qd1 = diff(q,x);
qd2 = diff(qd1,x);
qd3 = diff(qd2,x);

% horner notation to increase numeric stability
q=horner(q);
qd1=horner(qd1);
qd2=horner(qd2);
qd3=horner(qd3);

%% 1.b create equations for lower degree coefficients
if isJerk0
    constrVar = symVar(1:8).';
    designVar = symVar(9:end).'; % higher degree coeff.
else
    constrVar = symVar(1:6).';
    designVar = symVar(7:end).'; % higher degree coeff.
end

constrEq_bnd = sym.empty(6,0);
constrEq_bnd(1,1) = subs(q(1),x,timeLB)==posLB;
constrEq_bnd(2,1) = subs(qd1(1),x,timeLB)==speedLB;
constrEq_bnd(3,1) = subs(qd2(1),x,timeLB)==0;
constrEq_bnd(4,1) = subs(q(end),x,timeUB)==posUB;
constrEq_bnd(5,1) = subs(qd1(end),x,timeUB)==speedUB;
constrEq_bnd(6,1) = subs(qd2(end),x,timeUB)==0;
if isJerk0
    constrEq_bnd(7,1) = subs(qd3(1),x,timeLB)==0;
    constrEq_bnd(8,1) = subs(qd3(end),x,timeUB)==0;
end

sol = solve(constrEq_bnd,constrVar);
constrVar_sol=struct2array(sol).';

% q = subs(q,constrVar,constrVar_sol);
% qd1 = subs(qd1,constrVar,constrVar_sol);
% qd2 = subs(qd2,constrVar,constrVar_sol);
% qd3 = subs(qd3,constrVar,constrVar_sol);

%% 1.c print
% change to variable names in excel
syms time_x
disp(subs(q,x,time_x))
disp(subs(qd1,x,time_x))
disp(subs(qd2,x,time_x))
disp(subs(qd3,x,time_x))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. trapezoidal motion profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trapRatio = 1/3;

%% 2.a create equations for position, speed, acceleration and jerk
symVar = [];
% set ratios and max speed
dt = timeUB-timeLB;
if speedLB == 0 && speedUB == 0
    trapRatioAcc = trapRatio;
    trapRatioDec = trapRatio;
    qd1_max = (posUB-posLB)/(dt-(0.5*trapRatioAcc*dt)...
        -(0.5*trapRatioDec*dt));
else
    error(['trap motion profile with' ...
        'non-zero start/end speed not yet supported'])
end
% create velocity function
syms x
qd1 = sym.empty(3,0);
qd1(1) = qd1_max/(trapRatioAcc*dt)*(x-timeLB);
qd1(2) = qd1_max;
qd1(3) = -qd1_max/(trapRatioDec*dt)*(x-timeUB);
% calculate derivative
qd2 = diff(qd1,x);
qd3 = diff(qd2,x);
% solve system
syms C1 C2 C3
q = int(qd1,x);
eq = sym.empty(3,0);
eq(1) = subs(q(1),x,timeLB)+C1 == posLB;
eq(2) = subs(q(2),x,(dt*trapRatioAcc)+timeLB)+C2 == ...
    qd1_max*trapRatioAcc*dt/2+posLB; 
eq(3) = subs(q(3),x,timeUB)+C3 == posUB;
sol = solve(eq,[C1 C2 C3]);
q(1) = q(1)+sol.C1;
q(2) = q(2)+sol.C2;
q(3) = q(3)+sol.C3;
t = x;

%% 2.b print
% change to variable names in excel
syms time_x
disp(subs(q.',x,time_x))
disp(subs(qd1.',x,time_x))
disp(subs(qd2.',x,time_x))
disp(subs(qd3.',x,time_x))

% use following format to add multiple functions
% IF(time_x<-1+(2*1/3),FUN1,IF(time_x<-1+(2*2/3),FUN2,FUN3))

