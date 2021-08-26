function [prop] = defineProperties(obj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Read settings
sMechanism = obj.input.sMechanism;
posA = obj.input.posA;
posB = obj.input.posB;
isPosResc = obj.input.isPosResc;
d_J = obj.input.d_J;
d_Tl = obj.input.d_Tl;
dataJ = obj.input.dataJ;
dataTl = obj.input.dataTl;
isJSym = obj.input.isJSym;

% Determine properties
syms ph

% Define properties
% load data
fprintf('Reading of property data started. \n');
if isempty(dataTl)
    dataTl=readmatrix(strcat(sMechanism,'.xlsx'),'Sheet',2);
end
if isempty(dataJ) && ~isJSym
    dataJ=readmatrix(strcat(sMechanism,'.xlsx'),'Sheet',4);
end
fprintf('Property data is imported. \n\n');

% select 'usefull' part of property data
[~,iTl_1] = min(abs(dataTl(:,1)-posA)); % get closest value
[~,iTl_2] = min(abs(dataTl(:,1)-posB));
dataTl=dataTl(min(iTl_1,iTl_2):max(iTl_1,iTl_2),:);

if ~isJSym
    [~,iJ_1] = min(abs(dataJ(:,1)-posA)); % get closest value
    [~,iJ_2] = min(abs(dataJ(:,1)-posB));
    dataJ=dataJ(min(iJ_1,iJ_2):max(iJ_1,iJ_2),:);
end

% rescale
if isPosResc
    dataTl(:,1)=rescale(dataTl(:,1),-1,1);
    if ~isJSym
        dataJ(:,1)=rescale(dataJ(:,1),-1,1);
    end
end

% fit data (poly) -> convergence analysis with L2-norm
if isempty(d_Tl)
    d_Tl=0;
    while 1
        [a_Tl,S_Tl]=polyfit(dataTl(:,1),dataTl(:,2),d_Tl);
        %R2_Tl=1 - (S.normr/norm(dataTl(:,2) - mean(dataTl(:,2))))^2;
        L2_Tl=S_Tl.normr;
        if L2_Tl < 0.01
            break
        end
        d_Tl=d_Tl+1;
    end
else
    [a_Tl,S_Tl]=polyfit(dataTl(:,1),dataTl(:,2),d_Tl);
end
Tl=poly2sym(a_Tl,ph);
a_Tl=fliplr(a_Tl);
Tl_dis=dataTl(:,1:2);

if isJSym
    syms a0
    a_J=sym('a', [1 d_J]);
    a_J=[a0 a_J];
    pol=ph.^(0:d_J).';
    J=a_J*pol;
    J_dis = [];
    S_J.normr = [];
else
    if isempty(d_J)
        d_J=0;
        while 1
            [a_J,S_J]=polyfit(dataJ(:,1),dataJ(:,2),d_J);
            %R2_J=1 - (S.normr/norm(dataJ(:,2) - mean(dataJ(:,2))))^2;
            L2_J=S_J.normr;
            if L2_J < 0.001
                break
            end
            d_J=d_J+1;
        end
        
    else
        [a_J,S_J]=polyfit(dataJ(:,1),dataJ(:,2),d_J);
    end
    J=poly2sym(a_J,ph);
    a_J=fliplr(a_J);
    J_dis=dataJ(:,1:2);
end


Jd1=diff(J,ph); % inertia variation

% add to output
prop.Tl=Tl;
prop.J=J;
prop.Jd1=Jd1;
prop.d_Tl=d_Tl;
prop.d_J=d_J;
prop.a_Tl=a_Tl;
prop.a_J=a_J;
prop.Tl_dis=Tl_dis;
prop.J_dis=J_dis;
prop.L2_J=S_J.normr;
prop.L2_Tl=S_Tl.normr;

obj.prop = prop;

end

