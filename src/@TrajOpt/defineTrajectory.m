function [traj] = defineTrajectory(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% read obj.input
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
posA = obj.input.posA; % start position
posB = obj.input.posB; % end position
sTrajType = obj.input.sTrajType; % trajectory type
DOF = obj.input.DOF; % degree of freedom
nPieces = obj.input.nPieces; % #intervals
isTimeResc = obj.input.isTimeResc;
isPosResc = obj.input.isPosResc;
trapRatio = obj.input.trapRatio; % ratio t_acc/t_tot (trap)
trajFun = obj.input.trajFun; % custom symbolic trajectory function

%% define bounds
% check for resaling and define bounds
if isTimeResc
    timeLB=-1;
    timeUB=1;
else
    timeLB=timeA;
    timeUB=timeB;
end

if isPosResc
    posLB=-1;
    posUB=1;
else
    posLB=posA;
    posUB=posB;
end

%% define position function
syms x % time variable

% define position function
switch sTrajType
    case {'poly5','poly','cheb','cheb2'}
        % define symbolic variables
        syms p0
        symVar=sym('p', [1 5+DOF]);
        symVar=[p0 symVar];
        % create position fucntion
        switch sTrajType
            case 'poly5'
                pol=x.^(0:5).';
                q=symVar*pol;
            case 'poly'
                pol=x.^(0:5+DOF).';
                q=symVar*pol;
            case 'cheb'
                pol=chebyshevT(0:5+DOF,x).';
                q=symVar*pol;
            case 'cheb2'
                pol=chebyshevU(0:5+DOF,x).';
                q=symVar*pol;
        end
        % calculate derivatives
        qd1 = diff(q,x);
        qd2 = diff(qd1,x);       
    case 'spline'
        % define symbolic variables
        p0i= sym('p%d0',[1 nPieces]).';
        symVar = sym('p%d%d',[nPieces 3]);
        symVar = [p0i symVar];
        % create position function
        pol=x.^(0:3).';
        q=symVar*pol;    
    case 'trap'
        symVar = [];
        % create velocity function
        dt = timeUB-timeLB;
        qd1_max = (posUB-posLB)/((trapRatio*dt)+(dt-2*trapRatio*dt));
        qd1 = sym.empty(3,1);
        qd1(1,:) = qd1_max/(trapRatio*dt)*(x-timeLB);
        qd1(2,:) = qd1_max;
        qd1(3,:) = -qd1_max/(trapRatio*dt)*(x-timeUB);
        % calculate derivative
        qd2 = diff(qd1,x);
        % solve system
        syms C1 C2 C3
        q = int(qd1,x);
        eq = sym.empty(3,1);
        eq(1) = subs(q(1),x,timeLB)+C1 == posLB;
        eq(2) = subs(q(2),x,dt/2+timeLB)+C2 == ...
            abs(posUB-posLB)/2+min(posUB,posLB);
        eq(3) = subs(q(3),x,timeUB)+C3 == posUB;
        sol = solve(eq,[C1 C2 C3]);
        q = sym.empty(3,1);
        q(1,:) = q(1)+sol.C1;
        q(2,:) = q(2)+sol.C2;
        q(3,:) = q(3)+sol.C3;
        
    case 'custom'
        q=trajFun;
        qd1=diff(q);
        qd2=diff(qd1);
        
end

%% define breakpoints
switch sTrajType
    case 'trap'
        breaks = [timeLB,timeLB+trapRatio*dt,...
            timeUB-trapRatio*dt,timeUB];
    case 'spline'
        breaks = linspace(timeLB,timeUB,nPieces+1);
    case 'custom'
        breaks = trajFunBreaks;
    otherwise
        breaks=[timeLB,timeUB];
end

%% define constrained and design variables
switch sTrajType
    case {'poly5','poly','cheb','cheb2'}
        constrVar = symVar(1:6).';
        designVar = symVar(7:end).'; % higher degree coeff.
    case 'spline'
        constrVar=symVar(1:end).';
        designVar=sym('q', [1 nPieces]);
        designVar=designVar(2:nPieces-2).';
    otherwise
        constrVar =[];
        designVar =[];
end

%% define trajectory constraint equations
% start and end constraint equations
switch sTrajType
    case {'poly','poly5','cheb','cheb2','spline'}
        constrEq_bnd = sym.empty(6,0);
        constrEq_bnd(1,1) = subs(q(1),x,timeLB)==posLB;
        constrEq_bnd(2,1) = subs(qd1(1),x,timeLB)==0;
        constrEq_bnd(3,1) = subs(qd2(1),x,timeLB)==0;
        constrEq_bnd(4,1) = subs(q(end),x,timeUB)==posUB;
        constrEq_bnd(5,1) = subs(qd1(end),x,timeUB)==0;
        constrEq_bnd(6,1) = subs(qd2(end),x,timeUB)==0;
    otherwise
        constrEq_bnd =[];
end

% breakpoint constraint equations
switch sTrajType
    case 'spline'
        constrEq_br=sym(zeros(3*nPieces-3,1));
        for i=1:nPieces-1
            constrEq_br(3*i-2,1)=subs(q(i),x,breaks(i+1))==...
                subs(q(i+1),x,breaks(i+1));
            constrEq_br(3*i-1,1)=subs(qd1(i),x,breaks(i+1))==...
                subs(qd1(i+1),x,breaks(i+1));
            constrEq_br(3*i,1)=subs(qd2(i),x,breaks(i+1))==...
                subs(qd2(i+1),x,breaks(i+1));
        end
    otherwise
        constrEq_br=[];
end

% optimisation variables equations
switch sTrajType
    case 'spline'
        constrEq_var=sym(zeros(nPieces-3,1));
        for i=1:nPieces-3
            constrEq_var(i,1)=subs(q(i+2),x,breaks(i+2))==...
                designVar(i);
        end
    otherwise
        constrEq_var=[];
end

% combine constraint equations
constrEq=[constrEq_bnd; constrEq_br; constrEq_var];

%% solve constraint equations and substitute solution
% solve equations (eq) by solving constrained variables (constVar)
% as a function of the design variables (designVar)
switch sTrajType
    case {'poly5','poly','cheb','cheb2','spline'}
        fprintf('Solving constraint equations... \n');
        tic
        sol = solve(constrEq,constrVar);
        tsol=toc;
        fprintf(['Solution for constraint equations '...
            'found in %f s. \n\n'],tsol);
        constrVar_sol=struct2array(sol).';
        
        % replace constrained variables (constrVar) with equations obtained
        % from the solution (constrVar_sol)
        q = subs(q,constrVar,constrVar_sol);
        qd1 = subs(qd1,constrVar,constrVar_sol);
        qd2 = subs(qd2,constrVar,constrVar_sol);
    otherwise
        constrVar_sol =[];
        tsol = [];
end

%% horner
% change notation to horner
% if isHorner
%     q=horner(q);
%     qd1=horner(qd1);
%     qd2=horner(qd2);
% end

%% write output
traj.q=q;
traj.qd1=qd1;
traj.qd2=qd2;
traj.breaks=breaks;

traj.var.symVar=symVar;
traj.var.constrVar=constrVar;
traj.var.designVar=designVar;
traj.var.constrVar_sol=constrVar_sol;
traj.var.constrEq=constrEq;

traj.tsol=tsol;

obj.traj = traj;

end

