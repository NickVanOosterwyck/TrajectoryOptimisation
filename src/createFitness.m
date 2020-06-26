function [obj] = createFitness(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
% Read problem
timeA = obj.traj.timeA; % start time
timeB = obj.traj.timeB; % end time
posA = obj.traj.posA; % start position
posB = obj.traj.posB; % end position
DOF = obj.traj.DOF; % degrees of freedom
nInt = obj.traj.nInt;

isTimeResc = obj.traj.isTimeResc;
isPosResc = obj.traj.isPosResc;

sFitNot = obj.not.sFitNot;
isHorner = obj.not.isHorner;

% Read properties
Tl = prop.Tl;
J = prop.J;
Jd1 = prop.Jd1;

% Read trajectory
q = traj.q;
qd1 = traj.qd1;
qd2 = traj.qd2;
breaks = traj.breaks;
designVar = traj.var.designVar;

% check for resaling
if isTimeResc
    a=0.5*(timeB-timeA); % correction factor a
    lb_time=-1;
    ub_time=1;
else
    a=1;
    lb_time=timeA;
    ub_time=timeB;
end

if isPosResc
    b=0.5*(posB-posA); % correction factor b
else
    b=1;
end

if isPosResc
    c=2/(posB-posA); % correction factor c
else
    c=1;
end

% define motor torque
syms ph
tic
% write properties
Tl=subs(Tl,ph,q);
J=subs(J,ph,q);
Jd1=subs(Jd1,ph,q);
Tm=Tl+(J.*qd2/a^2/c)+(0.5*(Jd1/b).*(qd1/a/c).^2); % torque equation with scaling
Tm=expand(Tm); % expand and simplify function for easier integration

% define objective function
syms x
tic
fprintf('Integration of objective function started. \n');
if nInt==1
    fitFun=int(Tm^2,x,lb_time,ub_time);
else
    fitFun=sym(zeros(nInt,1));
    for i=1:nInt
        fitFun(i,1)=int(Tm(i).^2,x,breaks(i),breaks(i+1));
    end
end
%objFun = sqrt(1/(ub_time-lb_time)*ones(1,k)*objFun); % to prevent NaN
fitFun = 1/(ub_time-lb_time)*ones(1,nInt)*fitFun; % to prevent NaN
t_int=toc;
fprintf('Objective function integrated in %f s. \r\n',t_int);

tic
fprintf('Simplification of objective function started. \n');
fitFun=expand(fitFun); % simplification of objective function
t_sim=toc;
fprintf('Objective function simplified in %f s. \r\n',t_sim);

if isHorner
    fitFun=horner(fitFun);
end


%% create vectorized function handle
tic
fprintf('Vectorization of objective function started. \n');
if DOF>0
    old = arrayfun(@char, designVar, 'uniform', false); %sym2cell
    new=cell(DOF,1);
    for i=1:DOF
        new(i,1) = cellstr(['x(' num2str(i) ',:)']);
    end
    
    switch sFitNot
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
        case 'frac'
            fitFun_vec = char(fitFun);
        case 'vpa'
            fitFun_vec = char(vpa(fitFun));
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
obj.fitFun=fitFun;
obj.fitFun_vec=fitFun_vec;
obj.Tm=Tm;
obj.a=a;
obj.b=b;
obj.c=c;
obj.times=[t_int,t_sim,t_vec];

fprintf('%s\r\n','----------------------------------------------');

end

function fv = sym2vec(f,p)
%SYM2VEC converts a symbolic expression f with symbolic variables p into a
%"vectorized" form fv which is compatible with the INTLAB toolbox. The order
%in which 

n=size(p,2);
for i=1:n
    if ~has(f,p(i))
        error(['Symbolic function does not contain variable' char(p(i))])
    end
end

% convert symbolic functions and variables
pv = arrayfun(@char, p, 'uniform', false); %convert variables to cell
fv = matlabFunction(f,'Vars',p,'Optimize',false);
fv = func2str(fv);

%remove variable enumeration at beginning
ltot=sum(strlength(pv(1:end)));
ltot=ltot+n-1;
fv(3)='x';
fv(4:3+ltot-1)= [];

% replace variables with x(&)
for i=1:n
    lvar = strlength(pv(i));
    id = strfind(fv,pv(i));
    oc = size(id,2);
    for k=1:oc
        fv = [ fv(1:id(k)-1) 'x(' num2str(i) ')' fv(id(k)+lvar:end) ];
        id=id+4-lvar;
    end
end

eval(['fv = ' fv ';'])

% vectorize (INTLAB function)
%fv=funvec(fv,zeros(2,1));
 
end



