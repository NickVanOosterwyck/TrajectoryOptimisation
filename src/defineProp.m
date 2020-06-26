function [prop] = defineProp(problem)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Read settings
sMechanism = problem.gen.sMechanism;

posA = problem.traj.posA;
posB = problem.traj.posB;
isPosResc = problem.traj.isPosResc;

d_J = problem.prop.d_J;
d_Tl = problem.prop.d_Tl;

dataJ = problem.prop.dataJ;
dataTl = problem.prop.dataTl;

% Determine properties
syms ph

% Define properties
% load data
%fprintf('Reading of property data started. \n');
if ~isempty(dataTl)
    dataTl=xlsread(strcat(sMechanism,'.xlsx'),2);
end
if ~isempty(dataJ)
    dataJ=xlsread(strcat(sMechanism,'.xlsx'),4);
end
%fprintf('Property data is imported. \n\n');

% select 'useful' part of property data
[~,iTl_1] = min(abs(dataTl(:,1)-posA)); % get closest value
[~,iTl_2] = min(abs(dataTl(:,1)-posB));
dataTl=dataTl(min(iTl_1,iTl_2):max(iTl_1,iTl_2),:);

[~,iJ_1] = min(abs(dataJ(:,1)-posA)); % get closest value
[~,iJ_2] = min(abs(dataJ(:,1)-posB));
dataJ=dataJ(min(iJ_1,iJ_2):max(iJ_1,iJ_2),:);

% rescale
if isPosResc
    dataTl(:,1)=rescale(dataTl(:,1),-1,1);
    dataJ(:,1)=rescale(dataJ(:,1),-1,1);
end

% fit data (poly) -> convergence analysis with L2-norm
if isempty(d_Tl)
    d_Tl=0;
    while 1
        [p_Tl,S]=polyfit(dataTl(:,1),dataTl(:,2),d_Tl);
        %R2_Tl=1 - (S.normr/norm(dataTl(:,2) - mean(dataTl(:,2))))^2;
        L2_Tl=S.normr;
        if L2_Tl < 0.01
            break
        end
        d_Tl=d_Tl+1;
    end
else
    p_Tl=polyfit(dataTl(:,1),dataTl(:,2),d_Tl);
end

if isempty(d_J)
    d_J=0;
    while 1
        [p_J,S]=polyfit(dataJ(:,1),dataJ(:,2),d_J);
        %R2_J=1 - (S.normr/norm(dataJ(:,2) - mean(dataJ(:,2))))^2;
        L2_J=S.normr;
        if L2_J < 0.001
            break
        end
        d_J=d_J+1;
    end
    
else
    p_J=polyfit(dataJ(:,1),dataJ(:,2),d_J);
end

Tl=poly2sym(p_Tl,ph);
Tl=horner(Tl);
J=poly2sym(p_J,ph);
J=horner(J);

% vpa(p_J)?

Tl_dis=dataTl(:,1:2);
J_dis=dataJ(:,1:2);


Jd1=diff(J,ph); % inertia variation

% add to output
prop.Tl=Tl;
prop.J=J;
prop.Jd1=Jd1;
prop.d_Tl=d_Tl;
prop.d_J=d_J;
prop.p_Tl=p_Tl;
prop.p_J=p_J;
prop.Tl_dis=Tl_dis;
prop.J_dis=J_dis;

end

