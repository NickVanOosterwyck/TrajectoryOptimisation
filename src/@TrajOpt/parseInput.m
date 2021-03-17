function [inputC] = parseInput(obj,input)
%
% This function runs through the input struct and sets any missing fields
% to the default value. If a mandatory field is missing, then it throws an
% error.
%
% INPUTS:
%   input = a partially completed input struct
%
% OUTPUTS:
%   input = a complete input struct, with validated fields
%
% Copyright (C) 2020 Nick Van Oosterwyck <nick.vanoosterwyck@uantwerp.be>
% All rights reserved.
%
% This software may be modified & distributed under the terms
% of the GNU license. See LICENSE file in repo for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% sMechanism
% validate field
if ~isfield(input, 'sMechanism')
    error('Field ''sMechanism'' cannot be ommitted from ''input''');
end
inputC.sMechanism = input.sMechanism;

%% sTrajType
% validate field
if ~isfield(input, 'sTrajType')
    error('Field ''sTrajType'' cannot be ommitted from ''input''');
else
    validTrajTypes = {'trap','cvel','pause','poly','cheb','chebU',...
        'spline','custom','dis'};
    validatestring(input.sTrajType,validTrajTypes);
end
inputC.sTrajType = input.sTrajType;

%% timeA
% validate field
if ~isfield(input, 'timeA')
    error('Field ''timeA'' cannot be ommitted from ''input''');
else
    mustBeNumeric(input.timeA)
    mustBeNonnegative(input.timeA)
end
inputC.timeA = input.timeA;

%% timeB
% validate field
if ~isfield(input, 'timeB')
    error('Field ''timeB'' cannot be ommitted from ''input'''); 
else
    mustBeNumeric(input.timeB)
    mustBePositive(input.timeB)
end
% extra checks
if input.timeB < input.timeA
    error(['The value of field ''timeB'' must be greater than',...
        'the value of field ''timeB''.'])
end
inputC.timeB = input.timeB;

%% posA
% validate field
if ~isfield(input, 'posA')
    error('Field ''posA'' cannot be ommitted from ''input''');
else
    mustBeNumeric(input.posA)
end
inputC.posA = input.posA;

%% posB
% validate field
if ~isfield(input, 'posB')
    error('Field ''posB'' cannot be ommitted from ''input''');
else
    mustBeNumeric(input.posB)
end
inputC.posB = input.posB;

%% speedA
% validate field
if ~isfield(input,'speedA')
    input.speedA = 0;
else
    mustBeNumeric(input.speedA)
end
inputC.speedA = input.speedA;

%% speedB
% validate field
if ~isfield(input,'speedB')
    input.speedB = 0;
else
    mustBeNumeric(input.speedB)
end
% extra checks
switch inputC.sTrajType
    case {'cvel'}
        if isempty(input.speedB)
            error(['Field ''speedB'' cannot be ommitted from ''input'''...
                'for the selected trajectory type ''%s'''],input.sTrajType);
        end
end
inputC.speedB = input.speedB;

%% isJerk0
% validate field
if ~isfield(input,'isJerk0')
    input.isJerk0 = false;
else
    if ~islogical(input.isJerk0)
        error('Field ''isJerk0'' must be logical.')
    end
end
inputC.isJerk0 = input.isJerk0;

%% DOF
% validate field and assign default value if empty
if ~isfield(input,'DOF')
    input.DOF = 0;
else
    mustBeNonnegative(input.DOF);
    mustBeInteger(input.DOF)
end
% extra checks
switch inputC.sTrajType
    case {'trap','cvel','pause','custom'}
        if input.DOF ~= 0
            error(['The selected trajectory',...
                'type does not allow any DOF.'])
        end
%     case {'poly','cheb','chebU','spline'}
%         if input.DOF == 0
%             warning('The selected trajectory has no DOF.')
%         end
%     otherwise
end
inputC.DOF = input.DOF;

%% sSolver
% validate field
if ~isfield(input, 'sSolver')
    input.sSolver = [];
else
    validstrings = {'directCal','interior-point','quasi-newton','ga','intlab'};
    validatestring(input.sSolver,validstrings);
end
% extra checks
switch inputC.sTrajType
    case {'poly','cheb','chebU','spline'}
        if  inputC.DOF ~= 0
        if isempty(input.sSolver)
            error(['Field ''sSolver'' cannot be ommitted from ''input'''...
                'for the selected trajectory type ''%s'''],input.sTrajType);
        end
        end
end
inputC.sSolver = input.sSolver;

%% isTimeResc
if ~isfield(input, 'isTimeResc')
    input.isTimeResc = false;
else
    if ~islogical(input.isTimeResc)
        error('Field ''isTimeResc'' must be logical.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'spline','trap','cvel','custom'}
        if input.isTimeResc
            error(['The selected trajectory type ''%s'' does not allow ',...
                'field ''isTimeResc. to be true.'''],input.sTrajType)
        end
end
inputC.isTimeResc = input.isTimeResc;

%% isPosResc
if ~isfield(input, 'isPosResc')
    input.isPosResc = false;
else
    if ~islogical(input.isPosResc)
        error('Field ''isPosResc'' must be logical.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'spline','trap','cvel','custom'}
        if input.isPosResc
            error(['The selected trajectory type ''%s'' does not allow ',...
                'field ''isPosResc. to be true.'''],input.sTrajType)
        end
end
inputC.isPosResc = input.isPosResc;

%% trapRatio
% validate field and assign default value if empty
if ~isfield(input,'trapRatio')
    switch inputC.sTrajType
        case 'trap'
            input.trapRatio = 1/3;
        otherwise
            input.trapRatio = [];
    end
else
    mustBeNonnegative(input.trapRatio);
    mustBeLessThanOrEqual(input.trapRatio,0.5)
end
% extra checks
switch inputC.sTrajType
    case {'poly5','poly7','cvel','pause','poly','cheb','chebU','spline','custom'}
        if ~isempty(input.trapRatio)
            error(['The selected trajectory type ''%s'' does not allow a',...
                'field ''trapRatio.'''],input.sTrajType)
        end
end
inputC.trapRatio = input.trapRatio;

%% trajFun
% validate field and assign default value if empty
if ~isfield(input,'trajFun')
    input.trajFun = [];
else
    if ~isempty(input.trajFun) && ~isa(input.trajFun,'sym')
        error('Value must be symbolic.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'poly5','poly7','cvel','pause','trap','poly','cheb','chebU','spline'}
        if ~isempty(input.trajFun)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''trajFun.'''],input.sTrajType)
        end
        
end
inputC.trajFun = input.trajFun;

%% trajFunBreaks
% validate field and assign default value if empty
if ~isfield(input,'trajFunBreaks')
    input.trajFunBreaks = [];
else
    if ~isa(input.trajFunBreaks,'sym') && ~isnumeric(input.trajFunBreaks)
        error('Field ''trajFunBreaks'' must be numeric or symbolic.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'poly5','poly7','cvel','pause','trap','poly','cheb','chebU','spline'}
        if ~isempty(input.trajFunBreaks)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''trajFunBreaks'''],input.sTrajType)
        end
end
inputC.trajFunBreaks = input.trajFunBreaks;

%% traj
% validate field and assign default value if empty
if ~isfield(input,'traj')
    input.traj = [];
else
    if length(input.traj)>1 && ~isnumeric(input.traj)
        error('Only 1-dimensional trajectory data is allowed.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'poly5','poly7','cvel','pause','trap','poly','cheb','chebU','spline'}
        if ~isempty(input.traj)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''traj.'''],input.sTrajType)
        end 
    case {'dis'}
        if isempty(input.traj)
            error(['Field ''traj'' cannot be ommitted from ''input'''...
                'for the selected trajectory type ''%s'''],input.sTrajType);
        end  
end
inputC.traj = input.traj;

%% time
% validate field and assign default value if empty
if ~isfield(input,'time')
    input.time = [];
else
    if length(input.time)>1 && ~isnumeric(input.time)
        error('Only 1-dimensional time data is allowed.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'poly5','poly7','cvel','pause','trap','poly','cheb','chebU','spline'}
        if ~isempty(input.time)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''time.'''],input.sTrajType)
        end 
    case {'dis'}
        if isempty(input.time)
            error(['Field ''time'' cannot be ommitted from ''input'''...
                'for the selected trajectory type ''%s'''],input.sTrajType);
        end  
end
inputC.time = input.time;

%% sInterp
% check field
if ~isfield(input, 'sInterp')
    input.sInterp = 'poly';
else
    validInterpTypes = {'poly','cheb','none'};
    validatestring(input.sInterp,validInterpTypes);
end
inputC.sInterp = input.sInterp;

%% d_J
% validate field and assign default value if empty
if ~isfield(input,'d_J')
    input.d_J = [];
else
    mustBeInteger(input.d_J);
    mustBePositive(input.d_J);
end
inputC.d_J = input.d_J;

%% d_Tl
% validate field and assign default value if empty
if ~isfield(input,'d_Tl')
    input.d_Tl = [];
else
    mustBeInteger(input.d_Tl);
    mustBePositive(input.d_Tl);
end
inputC.d_Tl = input.d_Tl;

%% isJSym
if ~isfield(input, 'isJSym')
    input.isJSym = false;
else
    if ~islogical(input.isJSym)
        error('Field ''isJSym'' must be logical.')
    end
end
% extra checks
if input.isJSym && isempty(input.d_J)
    error('Field ''d_J'' must be specified when field ''isJSym'' is true.')
end
inputC.isJSym = input.isJSym;

%% dataJ
% validate field and assign default value if empty
if ~isfield(input,'dataJ')
    input.dataJ = [];
else
end
inputC.dataJ = input.dataJ;

%% data_Tl
% validate field and assign default value if empty
if ~isfield(input,'dataTl')
    input.dataTl = [];
else
end
inputC.dataTl = input.dataTl;

%% sFit
% validate field
if ~isfield(input, 'sFit')
    input.sFit = 'Trms';
else
    validstrings = {'Trms','Tmax'};
    validatestring(input.sFit,validstrings);
end
inputC.sFit = input.sFit;

%% sFitNot
% validate field
if ~isfield(input, 'sFitNot')
    input.sFitNot = 'frac';
else
    validstrings = {'frac','vpa','intval'};
    validatestring(input.sFitNot,validstrings);
end
inputC.sFitNot = input.sFitNot;

%% digits
% validate field and assign default value if empty
if ~isfield(input,'digits')
    switch input.sFitNot
        case 'vpa'
            input.digits = 32;
        otherwise
            input.digits = [];
    end
else
    mustBeInteger(input.digits);
    mustBeGreaterThanOrEqual(input.digits,2);
end
inputC.digits = input.digits;

%% isHornerNot
if ~isfield(input, 'isHornerNot')
    input.isHornerNot = false;
else
    if ~islogical(input.isHornerNot)
        error('Field ''isHornerNot'' must be logical.')
    end
end
inputC.isHornerNot = input.isHornerNot;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign dependent properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% nPieces
switch inputC.sTrajType
    case {'pause','poly','cheb','chebU','dis'}
        inputC.nPieces = 1;
    case {'cvel'}
        inputC.nPieces = 2;
    case {'trap'}
        inputC.nPieces = 3;
    case {'spline'}
        inputC.nPieces = inputC.DOF + 3;
    case {'custom'}
        inputC.nPieces = size(inputC.trajFun,1);
end

%% lb
% validate field and assign default value if empty
if ~isfield(input,'lb')
    switch inputC.sTrajType
        case 'spline'
            input.lb = min(inputC.posA,inputC.posB);
        case {'cheb','cheb2'}
            input.lb = -1;
        otherwise
            input.lb = [];
    end
else
    mustBeNumeric(input.lb);
end
inputC.lb = input.lb;

%% ub
% validate field and assign default value if empty
if ~isfield(input,'ub')
    switch inputC.sTrajType
        case 'spline'
            input.ub = max(inputC.posA,inputC.posB);
        case {'cheb','cheb2'}
            input.ub = 1;
        otherwise
            input.ub = [];
    end
else
    mustBeNumeric(input.ub);
end
% extra checks
if input.ub < input.lb
    error(['The value of field ''ub'' must be greater than',...
        'the value of field ''lb''.'])
end
inputC.ub = input.ub;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign validated input to property
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj.input = inputC;

end

