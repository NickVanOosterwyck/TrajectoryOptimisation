function [fit] = defineFitness(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
if isempty(obj.traj)
    obj.defineTrajectory();
end
if isempty(obj.prop)
    obj.defineProperties();
end

% Read problem
sTrajType = obj.input.sTrajType;
timeA = obj.input.timeA; % start time
timeB = obj.input.timeB; % end time
posA = obj.input.posA; % start position
posB = obj.input.posB; % end position
DOF = obj.input.DOF; % degrees of freedom
nPieces = obj.input.nPieces;
isTimeResc = obj.input.isTimeResc;
isPosResc = obj.input.isPosResc;
sFitNot = obj.input.sFitNot;
digits = obj.input.digits;
isHornerNot = obj.input.isHornerNot;

% Read properties
Tl = obj.prop.Tl;
J = obj.prop.J;
Jd1 = obj.prop.Jd1;

% Read trajectory
q = obj.traj.q;
qd1 = obj.traj.qd1;
qd2 = obj.traj.qd2;
t = obj.traj.t;
breaks = obj.traj.breaks;
designVar = obj.traj.var.designVar;

% check for rescaling
if isTimeResc
    a=0.5*(timeB-timeA); % correction factor = C4
    lb_time=-1;
    ub_time=1;
else
    a=1;
    lb_time=timeA;
    ub_time=timeB;
end

if isPosResc
    b=0.5*(posB-posA); % correction factor b = C3
    c=2/(posB-posA); % correction factor c = C1
else
    b=1;
    c=1;
end

% define motor torque
tic
fprintf('Determing torque Tm started. \n');
syms ph
switch sTrajType
    case 'dis'
        % write properties
        Tl=double(subs(Tl,ph,q));
        J=double(subs(J,ph,q));
        Jd1=double(subs(Jd1,ph,q));
        Tm=Tl+(J.*qd2/a^2/c)+(0.5*(Jd1/b).*(qd1/a/c).^2);
    otherwise
        % write properties
        Tl=subs(Tl,ph,q);
        J=subs(J,ph,q);
        Jd1=subs(Jd1,ph,q);
        Tm=Tl+(J.*qd2/a^2/c)+(0.5*(Jd1/b).*(qd1/a/c).^2); % torque equation with scaling
        Tm=expand(Tm); % expand and simplify function for easier integration
end
t_tor=toc;
fprintf('Torque Tm determined in %f s. \r\n',t_tor);

% define objective function
tic
fprintf('Integration of torque Tm started. \n');
switch sTrajType
    case 'dis'
        fitFun = rms(Tm)^2;
    otherwise
        if nPieces==1
            fitFun=int(Tm^2,t,lb_time,ub_time);
        else
            fitFun=sym(zeros(nPieces,1));
            for i=1:nPieces
                fitFun(i,1)=int(Tm(i).^2,t,breaks(i),breaks(i+1));
            end
        end
        fitFun = 1/(ub_time-lb_time)*ones(1,nPieces)*fitFun; % to prevent NaN     
end
t_int=toc;
fprintf('Torque Tm integrated in %f s. \r\n',t_int);

tic
fprintf('Simplification of objective function started. \n');
switch sTrajType
    case 'dis'
        t_sim = 0;
    otherwise
        fitFun=expand(fitFun); % simplification of objective function
        t_sim=toc;
end
fprintf('Objective function simplified in %f s. \r\n',t_sim);

if isHornerNot
    fitFun=horner(fitFun);
end

% create vectorized function handle
tic
fprintf('Vectorization of objective function started. \n');
if DOF>0
    switch sFitNot
        case 'frac'
            fitFun_vec = char(fitFun);
        case 'vpa'
            fitFun_vec = char(vpa(fitFun,digits));
        case 'intval'
            [C,T] = coeffs(fitFun);
            [N,D] = numden(C);
            n_t = size(N,2);
            fitFun_vec =char.empty;
            for i=1:n_t
                fitFun_vec = [fitFun_vec '+(intval(num2str(' char(N(i))...
                    '))/intval(num2str(' char(D(i)) '))*' char(T(i)) ')'];
            end
            fitFun_vec(1)=[]; % remove first '+' sign
    end
    old = arrayfun(@char, designVar, 'uniform', false); %sym2cell
    new=cell(DOF,1);
    for i=1:DOF
        new(i,1) = cellstr(['x(' num2str(i) ',:)']);
    end
    fitFun_vec = replace(fitFun_vec,old,new);
    fitFun_vec = vectorize(fitFun_vec);
    fitFun_vec = str2func(['@(x)' fitFun_vec]);
    t_vec=toc;
else
    fitFun_vec = fitFun;
    t_vec=0;
end
fprintf('Objective function vectorized in %f s. \n\n',t_vec);

% output data
fit.fitFun=fitFun;
fit.fitFun_vec=fitFun_vec;
fit.Tm=Tm;
fit.a=a;
fit.b=b;
fit.c=c;
fit.times=[t_tor,t_int,t_sim,t_vec];

obj.fit = fit;

end



