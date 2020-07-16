function [sol] = combineSolutions(sType,varargin)
%COMBINESOLUTIONS Summary of this function goes here
%   Detailed explanation goes here

nSol = nargin-1;

switch sType
    case 'sym'
        % combine solutions symbolically
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
                if ~isfield(varargin{i},'Tm')
                    for j = i-1:-1:1
                        if j<1
                            error(['Field ''Tm'' is missing or should be '...
                                'assigned in a preceding trajectory'])
                        end
                        if isa(varargin{j},'TrajOpt')
                            syms t
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
        
    case 'dis'
        % combine solutions discrete
        solt = struct.empty(nSol,0);
        for i=1:nSol
            if isa(varargin{i},'TrajOpt')
                solt(i).t = varargin{i}.res.DIS.t;
                solt(i).q = varargin{i}.res.DIS.q;
                solt(i).Tm = varargin{i}.res.DIS.Tm;
            else
                solt(i).t = varargin{i}.breaks(1):varargin{i}.ts:varargin{i}.breaks(2);
                n=length(solt(i).t);
                solt(i).q(1,1:n) = varargin{i}.q;
                
                if ~isfield(varargin{i},'Tm')
                    for j = i-1:-1:1
                        if j<1
                            error(['Field ''Tm'' is missing or should be '...
                                'assigned in a preceding trajectory'])
                        end
                        if isa(varargin{j},'TrajOpt')
                            solt(i).Tm(1,1:n) = varargin{j}.res.DIS.Tm(end);
                        end
                    end
                else
                    solt(i).Tm(1,1:n) = varargin{i}.Tm;
                end
            end
        end
        
        sol.t = [solt(:).t];
        sol.q = [solt(:).q];
        sol.Tm = [solt(:).Tm];
end


end

