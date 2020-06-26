function [sol, varargout] = optimizeTrajectory(problem,traj,fit)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% create peristent variable for INTLAB initialization
persistent isIntlabInit

% read input
DOF = problem.traj.DOF;

sAlgorithm = problem.solv.sAlgorithm;
lb = problem.solv.lb;
ub = problem.solv.ub;

designVar = traj.var.designVar;

fitFun = fit.fitFun;
fitFun_vec = fit.fitFun_vec;

% set search box
lb(1:DOF,1) = -1;
ub(1:DOF,1) = 1;

% bron?
% r = 1:DOF;
% r = 5+r;
% ub = 1./(posB.^r);
% lb = -1./(posB.^r);

% optimize
fprintf('%s\n','----------------------------------------------');
if DOF == 0
        t_sol=0;
        designVar_sol=[];
        fit_min=double(fitFun);
        data=[];

else
        fprintf(['Optimization of objective function with %d DOF ' ...
            'started with %s...\n'],DOF,sAlgorithm);
        switch sAlgorithm
            case 'directCal'
                % set equations
                eq=derivatives(fitFun,designVar);

                % optimize
                tic
                sol_dc =vpasolve(eq,designVar); %numeric
                t_sol=toc;

                % extract solution
                [designVar_sol,fit_min,n_sol]=extractSol(sol_dc,fitFun,designVar);
                designVar_sol=double(designVar_sol(1,:));
                fit_min=double(fit_min);
                
                % optional output
                data.n_sol = n_sol;
                data.eq=eq;

            case 'interior-point'
                % settings
                A = [];
                b = [];
                Aeq = [];
                beq = [];
                nonlcon =[];

                X0=zeros(DOF,1);

                options = optimoptions(@fmincon,'Display','off');

                % optimize
                tic
                [X,fit_min,exitflag,output] = fmincon(fitFun_vec,X0,A,b,...
                    Aeq,beq,lb,ub,nonlcon,options);
                t_sol = toc;

                % extract solution
                designVar_sol=X';
                
                % optional output
                data.exitflag=exitflag;
                data.output=output;
                
            case 'quasi-newton'
                % settings

                X0=zeros(DOF,1);
                
                options = optimoptions(@fminunc,'Display','final');

                % optimize
                tic
                [X,fit_min,exitflag,output] = fminunc(fitFun_vec,X0,...
                    options);
                t_sol = toc;

                % extract solution
                designVar_sol=X';
                
                % optional output
                data.exitflag=exitflag;
                data.output=output;
                
            case 'ga'
                % settings
                A = [];
                b = [];
                Aeq = [];
                beq = [];
                nonlcon =[];
                
                iPop = 1000; % PopulationSize
                iE = 10; % EliteCount
                iC = 0.6;   % CrossoverFraction
                
                % stopping condition
                iMaxTime = 600; % stopping time in [s]
                iMaxGen = 200;
                iStall = 50;
                
                options = optimoptions( @ga, ...
                    'PopulationSize', iPop, ...
                    'EliteCount', iE, ...
                    'CrossoverFraction',iC, ...
                    'FunctionTolerance',0, ... % TolFun
                    'ConstraintTolerance',0, ... % TolCon
                    'MaxTime',iMaxTime, ... % TimeLimit
                    'MaxGenerations',iMaxGen,... % Generations
                    'MaxStallGenerations',iStall, ... % StallGenLimit
                    'PlotFcn', {@gaplotbestf,@gaplotdistance}); % PlotFcns
                
                % optimize
                tic
                [X,fit_min,exitflag,output] = ga(fitFun_vec,DOF,A,b,...
                    Aeq,beq,lb,ub,nonlcon,options);
                t_sol=toc;
                
                % extract solution
                designVar_sol=X';
                
                % optional output
                data.exitflag=exitflag;
                data.output=output;

            case 'intlab'
                % init
                if isempty(isIntlabInit)
                    isIntlabInit = false;
                end
                if ~isIntlabInit
                    cwd=cd(['C:\Program Files\MATLAB\R' ...
                        version('-release') '\toolbox\INTLAB\Intlab_V11']);
                    startintlab;
                    cd(cwd);
                    isIntlabInit=true;
                    format infsup long e % change display of intervals
                end
                %format infsup

                % settings
                % set interval bounds
                if ~isempty(lb)
                    X0 = infsup(problem.lb,problem.ub)*ones(DOF,1);
                else
                    X0 = infsup(-1,1)*ones(DOF,1);
                end
                opt = verifyoptimset('NIT',1,'TolFun',0.001);

                % solve
                it=1;
                fprintf(['Iteration: %d   Boxes left:%d    Time '...
                    'elapsed: %4.2f s\n'],it,Inf,0)
                tic
                [ mu , X , XS , Data ] = verifyglobalmin(fitFun_vec,X0,opt);
                XS = collectList(XS);
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
                
                % optional output
                data.X=X;
                data.Data=Data;
        end
             
end

fprintf('Solution found in %4.2f s\n',t_sol);
fprintf('%s\r\n','----------------------------------------------');

sol.designVar_sol=designVar_sol;
sol.fit_val=fit_min;
sol.t_sol=t_sol;
sol.Data=data;

end

function [dif] = derivatives(func,var)
dif=sym(zeros(1,length(var)));
for i=1:length(var)
    dif(1,i) = diff(func,var(i))==0;
    %dif(1,i) = simplify(dif(1,i));
end
end
function [p_sor,obj_sor,n_sol_real] = extractSol(sol_dc,objFun,optvar)
% extracts all the real solutions of the solution

% check if more than 1 variable
if isa(sol_dc,'struct')
    solc = struct2cell(sol_dc); %convert to cell array
    solM = [solc{1:end}]; %combine results to matrix
else
    solM=sol_dc;
end
n_sol=size(solM,1);

% extract real solutions (code can be optimized)
k=0;
for i=1:n_sol
    if isreal(solM(i,:))
        k=k+1;
        p(k,:)= solM(i,:);
    end
end
n_sol_real=k;

% rank solutions
if n_sol_real > 1
    obj_val=sym(zeros(1,n_sol_real));
    for i=1:n_sol_real
        obj_val(i)=subs(objFun,optvar.',p(i,:));
    end
    
    [obj_sor,I]=sort(obj_val);
    obj_sor=obj_sor';
    
    p_sor=sym(zeros(n_sol_real,size(solM,2)));
    for i=1:n_sol_real
        p_sor(i,:)=p(I(i),:);
    end
else
    p_sor=p(1,:);
    obj_sor=subs(objFun,optvar.',p(1,:));
end

end



