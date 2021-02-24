function [res] = parseSolution(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% read input
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
posA = obj.input.posA; % start position
posB = obj.input.posB; % end position
sTrajType = obj.input.sTrajType; % trajectory type
nPieces = obj.input.nPieces; % #intervals
isTimeResc = obj.input.isTimeResc;
isPosResc = obj.input.isPosResc;

q = obj.traj.q;
qd1 = obj.traj.qd1;
qd2 = obj.traj.qd2;
qd3 = obj.traj.qd3;
time = obj.traj.t;
breaks = obj.traj.breaks;
designVar = obj.traj.var.designVar;
constrVar_sol = obj.traj.var.constrVar_sol;

Tl = obj.prop.Tl;
J = obj.prop.J;

fitFun = obj.fit.fitFun;

designVar_sol = obj.sol.designVar_sol;

% define trajectory according to constraints
switch sTrajType
    case 'dis'
        q_C = q;
        qd1_C = qd1;
        qd2_C = qd2;
        qd3_C = qd3;
        breaks_C = breaks;
        t_C = time;
    otherwise
        % fill in trajectory with solution
        q=subs(q,designVar.',designVar_sol);
        
        syms t
        % rescale q horizontally
        if isTimeResc
            q_C=subs(q,time,((2*t)-(timeB+timeA))/(timeB-timeA));
            breaks_C = rescale(breaks,timeA,timeB);
        elseif ~isTimeResc
            q_C=subs(q,time,t);
            breaks_C = breaks;
        end
        
        % rescale q vertically
        if isPosResc
            q_C=((1/2*(posB-posA))*q_C) + (1/2*(posB+posA));
        end
        
        qd1_C = diff(q_C,t);
        qd2_C = diff(qd1_C,t);
        qd3_C = diff(qd2_C,t);
        t_C = t;
end

% rescale properties horizontally
syms ph th
if isPosResc
    Tl_C=subs(Tl,ph,((2*th)-(posB+posA))/(posB-posA));
    J_C=subs(J,ph,((2*th)-(posB+posA))/(posB-posA));
elseif ~isPosResc
    Tl_C=subs(Tl,ph,th);
    J_C=subs(J,ph,th);
end
Jd1_C=diff(J_C,th);

syms th
switch sTrajType
    case 'dis'
        Tload_C=double(subs(Tl_C,th,q));
        Inertia_C=double(subs(J_C,th,q));
        Inertia_d1_C=double(subs(Jd1_C,th,q));
        
        Tacc_C = Inertia_C.*qd2_C;
        Tvar_C = 0.5.*Inertia_d1_C.*(qd1_C.^2);
        
        Tm_C = Tload_C + Tacc_C + Tvar_C;
        
    otherwise
        Tload_C = Tl_C;
        Tacc_C = J_C.*qd2_C;
        Tvar_C = 0.5.*Jd1_C.*(qd1_C.^2);

        Tm_C = Tload_C + Tvar_C + Tacc_C; %torque equation
        
        for i=1:nPieces
            Tm_C(i)=subs(Tm_C(i),th,q_C(i));
            Tacc_C(i)=subs(Tacc_C(i),th,q_C(i));
            Tvar_C(i)=subs(Tvar_C(i),th,q_C(i));
        end
        
        Tload_C=subs(Tload_C,th,q_C);
        Inertia_C=subs(J_C,th,q_C);
        Inertia_d1_C=subs(Jd1_C,th,q_C);
end

% calculate Trms
switch sTrajType
    case 'dis'
        Trms_C = rms(Tm_C);
    otherwise
        syms t
        %Trms_C=double(sqrt(1/2*subs(objFun,p_sym(7:n+1),p(7:n+1))));
        Trms_C=double(sqrt(subs(fitFun,designVar.',designVar_sol)));
        %Trms_C=double(sqrt(1/2*int(Tm_C^2,t,t_A,t_B))); % alternative
end

% evaluate discrete
switch sTrajType
    case 'dis'
        t_dis = t_C;
        q_dis = q_C;
        qd1_dis = qd1_C;
        qd2_dis = qd2_C;
        qd3_dis = qd3_C;
        Tm_dis = Tm_C;
        ts = t_C(2)-t_C(1);
    otherwise
        ts = 0.00025;
        t_dis = double(breaks_C(1):ts:breaks_C(end));
        ind = 1;
        for i=1:nPieces
            if i ~= nPieces
                t_temp = t_dis(t_dis>=breaks_C(i) & t_dis<breaks_C(i+1));
            else
                t_temp = t_dis(t_dis>=breaks_C(i) & t_dis<=breaks_C(i+1));
            end
            n=length(t_temp);
            q_dis(ind:ind+n-1) = double(subs(q_C(i),t,t_temp));
            qd1_dis(ind:ind+n-1) = double(subs(qd1_C(i),t,t_temp));
            qd2_dis(ind:ind+n-1) = double(subs(qd2_C(i),t,t_temp));
            qd3_dis(ind:ind+n-1) = double(subs(qd3_C(i),t,t_temp));
            Tm_dis(ind:ind+n-1) = double(subs(Tm_C(i),t,t_temp));
            ind=ind+n;
        end
end

% calculate Tmax & Trms discrete
%Tm_tot = reshape(Tm_dis,1,[]);
Tmax_dis = max(abs(Tm_dis));
Trms_dis = rms(Tm_dis);

% determine coefficients of polynomial
p_sol = subs(constrVar_sol,designVar.',designVar_sol).';
p_sol = [p_sol designVar_sol];
p_sol = double(p_sol);

% coefficients of standard polynomial
switch sTrajType
    case {'poly','cheb','chebU'}
        p_pol=fliplr(double(coeffs(q_C(i),'All')));
    case 'spline'
        p_pol=zeros(nPieces,4);
        for i=1:nPieces
            p_pol(i,:)=fliplr(double(coeffs(q_C(i),'All')));
        end
    otherwise
        p_pol=[];
end

% set ouput
res.q = q_C;
res.qd1 = qd1_C;
res.qd2 = qd2_C;
res.qd3 = qd3_C;
res.t = t_C;
res.breaks = breaks_C;
res.Tm = Tm_C;
%res.J = J_C;
%res.Jd1 = J_d1_C;
%res.Tl = Tl_C;
res.Trms = Trms_C;
res.Trms_dis = Trms_dis;
res.Tmax_dis = Tmax_dis;
res.DIS.t = t_dis;
res.DIS.q = q_dis;
res.DIS.qd1 = qd1_dis;
res.DIS.qd2 = qd2_dis;
res.DIS.qd3 = qd3_dis;
res.DIS.Tm = Tm_dis;
res.DIS.ts = ts;
res.TE.Tload = Tload_C;
res.TE.Inertia = Inertia_C;
res.TE.Inertia_d1 = Inertia_d1_C;
res.TE.Tacc = Tacc_C;
res.TE.Tvar = Tvar_C;
res.p_sol=p_sol;
res.p_pol=p_pol;

obj.res = res;

end

