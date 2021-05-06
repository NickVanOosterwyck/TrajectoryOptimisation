%%
clear input
% required
input.sMechanism = 'Nedschroef';
input.sTrajType = 'poly';
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
input.isPosResc = false;

mop = TrajOpt(input);
mop.defineTrajectory();
mop.optimizeTrajectory();
q = mop.traj.q

%%
syms p0
symVar=sym('p', [1 9]);
symVar=[p0 symVar];
syms x
pol=x.^(0:9).';
q=symVar*pol;
qd1 = diff(q,x);
qd2 = diff(qd1,x);

syms pA pB
timeLB = -1;
timeUB = 1;
constrEq_bnd = sym.empty(6,0);
constrEq_bnd(1,1) = subs(q(1),x,timeLB)==pA;
constrEq_bnd(2,1) = subs(qd1(1),x,timeLB)==0;
constrEq_bnd(3,1) = subs(qd2(1),x,timeLB)==0;
constrEq_bnd(4,1) = subs(q(end),x,timeUB)==pB;
constrEq_bnd(5,1) = subs(qd1(end),x,timeUB)==0;
constrEq_bnd(6,1) = subs(qd2(end),x,timeUB)==0;
sol = solve(constrEq_bnd,symVar(1:6));
constrVar_sol=struct2array(sol);
q = subs(q,symVar,constrVar_sol);
qd1 = subs(q,symVar,constrVar_sol);
qd2 = subs(q,symVar,constrVar_sol);

%%
clear input
input.sTrajType = 'trap';
input.timeA = 0;
% input.timeB = 1;
% input.posA = 2;
% input.posB = 1;
trap = CADTraj(input);
obj = trap;

% read obj.input
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
posA = obj.input.posA; % start position
posB = obj.input.posB; % end position
speedA = obj.input.speedA; % start speed
speedB = obj.input.speedB; % end speed
isJerk0 = obj.input.isJerk0; % is jerk 0 in start and endpoint
sTrajType = obj.input.sTrajType; % trajectory type
DOF = obj.input.DOF; % degree of freedom
nPieces = obj.input.nPieces; % #intervals
trapRatio = obj.input.trapRatio; % ratio t_acc/t_tot (trap)
trajFun = obj.input.trajFun; % custom symbolic trajectory function
trajFunBreaks = obj.input.trajFunBreaks;

timeLB=timeA;
timeUB=timeB;
posLB=posA;
posUB=posB;
speedLB = speedA;
speedUB = speedB;

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
