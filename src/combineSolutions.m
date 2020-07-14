function [sol] = combineSolutions(varargin)
%COMBINESOLUTIONS Summary of this function goes here
%   Detailed explanation goes here

% check input
nSol = nargin;

% combine solutions
sol = struct.empty(nSol,0);
for i=1:nSol
    if isa(varargin{i},'TrajOpt')
        sol(i).q = varargin{i}.res.q;
        sol(i).breaks = varargin{i}.res.breaks;
        sol(i).Tm = varargin{i}.res.Tm;
        sol(i).nPieces = varargin{i}.input.nPieces;
    else
        sol(i).q = varargin{i}.q;
        sol(i).breaks = varargin{i}.breaks;
        if isempty(varargin{i}.Tm)
            for j = nargin:1
                if j<1
                    error(['Field ''Tm'' is missing or should be '...
                        'assigned in a preceding trajectory'])
                end
                if ~isempty(varargin{j})
                    sol(i).Tm = subs(varargin{j}.res.Tm(end),...
                        t,varargin{i}.breaks(1));
                end
            end
        else
            sol(i).Tm = varargin{i}.Tm;
        end
        sol(i).nPieces = length(varargin{i}.q);
    end
end


end

