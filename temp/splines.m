%% init
clear; clc; %close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))
% latex
set(0,'DefaultTextInterpreter','latex');
set(0,'DefaultLegendInterpreter','latex');
set(0,'DefaultAxesTickLabelInterpreter','latex');
% intlab
cwd=cd(['C:\Program Files\MATLAB\R' ...
    version('-release') '\toolbox\INTLAB\Intlab_V11']);
startintlab;
cd(cwd);
format infsup %long e % change display of intervals

%% input
% breakpoints
n = 5;
t0 = -1;
tn = 1';
ti = linspace(t0,tn,n+1);

% thetai (symbolic)
syms th0
thi=sym('th', [1 n]);
thi=[th0 thi];

% z_i (symbolic)
syms z0;
zi=sym('z', [1 n]);
zi=[z0 zi];

% constraints
thA = -1;
thB = 1;
thi(1) = thA;
thi(n+1) = thB;
zi(1) = 0;
zi(n+1) = 0;

% inertia
syms th
b_J = [0.012438014347721,6.097620376184698e-05,-0.017573048370808,...
    6.302708402890077e-05,0.008885823771286];
J = b_J*(th.^(0:4).');
Jd1 = diff(J,th);

%% splines
syms t
C=sym(zeros(n,1));
for k=0:n-1
    i=k+1;
    C(i) = zi(i+1)*n/12*(t-ti(i))^3 + zi(i)*n/12*(ti(i+1)-t)^3 + ...
        ((thi(i+1)*n/2)-(1/3/n*zi(i+1)))*(t-ti(i)) + ...
        ((thi(i)*n/2)-(1/3/n*zi(i)))*(ti(i+1)-t);
end

Cd1 = diff(C,t);
Cd2 = diff(Cd1,t);

% test for C''
% Cd2b=sym(zeros(n,1));
% for k=0:n-1
%     i=k+1;
%     Cd2b(i) = (zi(i+1)-zi(i))*n/2*(t-ti(i)) + zi(i);
% end

%% constraints (matrix)
Aeq = zeros(n+1,2*n-2);
% knot constraints
a_th = [3*n -6*n 3*n];
a_z = [-2/n -8/n -2/n];
for i=1:n-1 % may be sped up with 'diag' command
    for k=1:3
        in=i-2+k;
        if in>0 && in<n
            Aeq(i,in) = a_th(k);
            Aeq(i,in+n-1) = a_z(k);
        end
    end
end
% speed constraints
Aeq(n,1) = 2;
Aeq(n,n) = -1/12;
Aeq(n+1,n-1) = 2;
Aeq(n+1,2*n-2) = -1/12;

beq = zeros(n+1,1);
% knot constraints
beq(1) = -3*n*thA;
beq(n-1) = -3*n*thB;
% speed constraints
beq(n) = 2*thA;
beq(n+1) = 2*thB;

%% constraints (equation)
% con=sym(zeros(n-1,1));
% for k=1:n-1
%     i=k+1;
%     con(i-1) = 2/n*zi(i-1) + 8/n*zi(i) + 2/n*zi(i+1) == ...
%         3*n*thi(i-1) - 6*n*thi(i) + 3*n*thi(i+1);
% end
% 
% con(end+1) = subs(Cd1(1),t,-1)==0;
% con(end+1) = subs(Cd1(n),t,1)==0;

%% fitness function
Ji = subs(J,th,C);
Jd1i = subs(Jd1,th,C);
Tm = Ji.*Cd2 + 1/2*Jd1i.*Cd1.^2;

%Tm = simplify(Tm); % no effect

fprintf('Integration of torque Tm started. \n');
fi=sym(zeros(n,1));
for k=0:n-1
    i=k+1;
    tic
    fi(i) = int(Tm(i).^2,t,ti(i),ti(i+1));
    t_int(i) = toc;
end
msg =  ['Torque Tm integrated in: [', repmat('%g, ', 1, numel(t_int)-1), '%g] s\n'];
fprintf(msg,t_int);

fprintf('Simplification of objective function started. \n');
for i=1:n
    tic
    fi(i) = simplify(fi(i)); % necessary, but VERY slow!
    t_sim(i)=toc;
end
msg =  ['Objective function simplified in: [', repmat('%g, ', 1, numel(t_sim)-1), '%g] s\n'];
fprintf(msg,t_sim);

fitFun = ones(1,n)*fi;

% horner
tic
designVar = [thi(2:end-1),zi(2:end-1)].';
for i=1:length(designVar)
    fitFun = horner(fitFun,designVar(i));
end
toc

%fitFun = simplify(fitFun); % no effect

% deg = polynomialDegree(fitFun);
% coef_max = double(max(abs(coeffs(fitFun))));
% coef_min = double(min(abs(coeffs(fitFun))));

%% plot objective
j = 1;
sol = solve(Aeq*designVar==beq,designVar([1:j-1,j+1:end]));
sol_array=struct2array(sol).';
fitFun_plot = subs(fitFun,designVar([1:j-1,j+1:end]),sol_array);
fitFun_plot = expand(fitFun_plot);
figure
fplot(log(fitFun_plot),[-1,1])
xlabel(['$' char(designVar(j)) '$'])
ylabel('$log(T_{rms})$')

ax = gca; 
outerpos = ax.OuterPosition; 
ti = ax.TightInset;  
left = outerpos(1) + ti(1); 
bottom = outerpos(2) + ti(2); 
ax_width = outerpos(3) - ti(1) - ti(3); 
ax_height = outerpos(4) - ti(2) - ti(4); 
ax.Position = [left bottom ax_width ax_height]; 

%% create vectorized fitness function
tic
fprintf('Vectorization of objective function started. \n');

d = n*2-2; % # design var

fitFun_vec = char(fitFun);
old = arrayfun(@char, designVar, 'uniform', false); %sym2cell
new=cell(d,1);
for i=1:d
    new(i,1) = cellstr(['x(' num2str(i) ',:)']);
end
fitFun_vec = replace(fitFun_vec,old,new);
fitFun_vec = vectorize(fitFun_vec);
fitFun_vec = str2func(['@(x)' fitFun_vec]);
t_vec=toc;
fprintf('Objective function vectorized in %f s. \n\n',t_vec);

%% create vectorized constraints
tic
fprintf('Vectorization of constraints started. \n');

designVar = [thi(2:end-1),zi(2:end-1)].';
d = n*2-2; % # design var

con_vec = char(Aeq*designVar-beq);
old = arrayfun(@char, designVar, 'uniform', false); %sym2cell
new=cell(d,1);
for i=1:d
    new(i,1) = cellstr(['x(' num2str(i) ',:)']);
end
con_vec = replace(con_vec,old,new);
con_vec = vectorize(con_vec);
con_vec = str2func(['@(x)' con_vec]);
t_vec=toc;
fprintf('Constraints vectorized in %f s. \n\n',t_vec);

%% optimise fmincon
X0=zeros(d,1);
A = [];
b = [];
lb = [];
ub = [];
nonlcon =[];
options = optimoptions(@fmincon,'Display','none');

% optimize
tic
[X,fit_min,exitflag,output] = fmincon(fitFun_vec,X0,A,b,...
    Aeq,beq,lb,ub,nonlcon,options);
t_sol = toc;

designVar_sol=X';

%% optimise intlab
X0_th = infsup(-1,1)*ones(n-1,1);
X0_z = infsup(-10,10)*ones(n-1,1);
X0 = [X0_th;X0_z];
opt = verifyoptimset('NIT',1,'TolFun',0.001);

% solve
it=1;
fprintf(['Iteration: %d   Boxes left:%d    Time '...
    'elapsed: %4.2f s\n'],it,Inf,0)
tic
[ mu , X , XS , Data ] = verifyconstraintglobalmin(fitFun_vec,con_vec,X0,opt);
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

%% plot
% substitute solution
C_sol = subs(C,designVar.',designVar_sol);
Cd1_sol = subs(Cd1,designVar.',designVar_sol);
Cd2_sol = subs(Cd2,designVar.',designVar_sol);
Tm_sol = subs(Tm,designVar.',designVar_sol);

figure
hold on
subplot(2,2,1); hold on
xlabel('$t [s]$')
ylabel('$\theta [rad]$')
for i=1:n
    fplot(C_sol(i),[ti(i),ti(i+1)])
end
subplot(2,2,2); hold on
xlabel('$t [s]$')
ylabel('$T_m [Nm]$')
for i=1:n
    fplot(Tm_sol(i),[ti(i),ti(i+1)])
end
subplot(2,2,3); hold on
xlabel('$t [s]$')
ylabel('$\dot{\theta} [rad/s]$')
for i=1:n
    fplot(Cd1_sol(i),[ti(i),ti(i+1)])
end
subplot(2,2,4); hold on
xlabel('$t [s]$')
ylabel('$\ddot{\theta} [rad/s^2]$')
for i=1:n
    fplot(Cd2_sol(i),[ti(i),ti(i+1)])
end

%% Tm to latex
% syms theta_1 theta_2 z_1 z_2
% Tm = subs(Tm,thi(2),theta_1);
% Tm = subs(Tm,thi(3),theta_2);
% Tm = subs(Tm,zi(2),z_1);
% Tm = subs(Tm,zi(3),z_2);
% Tm_latex = latex(Tm);
 
%% fi to latex
% syms theta_1 theta_2 z_1 z_2
% fi = subs(fi,thi(2),theta_1);
% fi = subs(fi,thi(3),theta_2);
% fi = subs(fi,zi(2),z_1);
% fi = subs(fi,zi(3),z_2);
% fi_latex = latex(vpa(fi(2),4));
% 
% fileID = fopen('fi.txt','w');
% fprintf(fileID,'%s\n',fi_latex);
% fclose(fileID);

