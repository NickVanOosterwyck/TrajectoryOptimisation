function [res] = evalSol(problem,traj,prop,fit,sol)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% read input
timeA = problem.traj.timeA; % start time
timeB = problem.traj.timeB; % end time
posA = problem.traj.posA; % start position
posB = problem.traj.posB; % end position
sTrajType = problem.traj.sTrajType; % trajectory type
nInt = problem.traj.nInt; % #intervals
isTimeResc = problem.traj.isTimeResc;
isPosResc = problem.traj.isPosResc;

q=traj.q;
br = traj.breaks;
designVar=traj.var.designVar;
constrEq=traj.var.constrEq;

Tl=prop.Tl;
J=prop.J;

fitFun=fit.fitFun;

designVar_sol=sol.designVar_sol;

% determine coefficients
p_sol = subs(constrEq,designVar.',designVar_sol).';
p_sol = [p_sol designVar_sol];
p_sol= double(p_sol);

% fill in trajectory with solution
q=subs(q,designVar.',designVar_sol);
%q=simplify(q);
%Tm=subs(Tm,p_sym(7:n+1),optvar_sol);

% rescale q horizontally
syms x t ph th
if isTimeResc
    q_C=subs(q,x,((2*t)-(timeB+timeA))/(timeB-timeA));
elseif ~isTimeResc
    q_C=subs(q,x,t);
% elseif isTrajResc && x_A ~=-1 && x_B ~=1
%     q_C=subs(q,x,((t_B-t_A)/(x_B-x_A)*(x-x_A))+t_A);
end

% rescale q vertically
if isPosResc
    q_C=((1/2*(posB-posA))*q_C) + (1/2*(posB+posA));
end

qd1_C = diff(q_C,t);
qd2_C = diff(qd1_C,t);

% rescale properties horizontally
if isPosResc
    Tl_C=subs(Tl,ph,((2*th)-(posB+posA))/(posB-posA));
    J_C=subs(J,ph,((2*th)-(posB+posA))/(posB-posA));
elseif ~isPosResc
    Tl_C=subs(Tl,ph,th);
    J_C=subs(J,ph,th);
end
J_d1_C=diff(J_C,th);

% compose torque equation
Tload_C = Tl_C;
Tacc_C = J_C*qd2_C;
Tvar_C = 0.5*J_d1_C*(qd1_C.^2);

Tm_C = Tload_C + Tvar_C + Tacc_C; %torque equation

syms th
Inertia_C=subs(J_C,th,q_C); %temp
Inertia_d1_C=subs(J_d1_C,th,q_C); %temp

Tload_C=subs(Tload_C,th,q_C);
Tacc_C=subs(Tacc_C,th,q_C);
Tvar_C=subs(Tvar_C,th,q_C);
Tm_C=subs(Tm_C,th,q_C);

% calculate Trms
syms t
%Trms_C=double(sqrt(1/2*subs(objFun,p_sym(7:n+1),p(7:n+1))));
Trms_C=double(sqrt(subs(fitFun,designVar.',designVar_sol)));
%Trms_C=double(sqrt(1/2*int(Tm_C^2,t,t_A,t_B))); % alternative

% calculate Trms discrete
Tmax=0;
for i=nInt
    ts = linspace(br(i),br(i+1),100);
    y = double(subs(Tm_C(i),t,ts));
    Tmax = max(max(abs(y)),Tmax);
end
    Trms_dis = rms(y);

% coefficients of standard polynomial
switch sTrajType
    case {'poly5','poly','cheb','cheb2'}
        %p_pol=zeros(nInt,n_tr+1);
        for i=1:nInt
            p_pol(i,:)=double(coeffs(q_C(i),'All'));
        end
    otherwise
        p_pol=[];
end

% set ouput
res.q=q_C;
res.qd1=qd1_C;
res.qd2=qd2_C;
res.Tm = Tm_C;
res.J = J_C;
res.Jd1 = J_d1_C;
res.Tl = Tl_C;
res.Tload = Tload_C;
res.Inertia = Inertia_C;
res.Inertia_d1 = Inertia_d1_C;
res.Tacc = Tacc_C;
res.Tvar = Tvar_C;
res.Tmax=Tmax;
res.Trms = Trms_C;
res.Trms_dis = Trms_dis;
res.p_sol=p_sol;
res.p_pol=p_pol;

end
