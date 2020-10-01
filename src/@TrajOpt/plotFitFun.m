function [] = plotFitFun(obj,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% input parser
p = inputParser;
defScale = 'log';
p.addOptional('Scale',defScale,@ischar) %log or lin
p.parse(varargin{:});
Scale=p.Results.Scale;

% read objective
objFun = obj.fit.fitFun;
DOF = obj.input.DOF;
lb = obj.input.lb;
ub = obj.input.ub;

% read settings
sTrajType = obj.input.sTrajType;

switch sTrajType
    case {'trap','poly5','pause'}
        error ('Only possible to plot trajectory.')
    case {'poly','cheb','chebU'}
        labX = '$p_6$';
        labY = '$p_7$';
    case 'spline'
        labX = '$q_2$';
        labY = '$q_3$';
    case 'custom'
        labX = '$x_1$';
        labY = '$x_2$';
    otherwise
        error(['Fitness function cannot be plotted for the selected '...
            'trajectory type ''%s'''],obj.input.sTrajType);
end

switch DOF
    case 1
        switch Scale
            case 'log'
                % plot log
                figure('renderer','painters');
                a = axes;
                fplot(log10(objFun),[lb,ub]); % plot
                
                % axes
                a.TickLabelInterpreter = 'latex';
                xlabel(labX,'Interpreter','latex')
                ylabel('$T_{rms}$','Interpreter','latex')
            case 'lin'
                % plot lin
                figure('renderer','painters');
                a = axes;
                fplot(objFun,[lb,ub]); % plot
                
                % axes
                a.TickLabelInterpreter = 'latex';
                xlabel(labX,'Interpreter','latex')
                ylabel('$T_{rms}$','Interpreter','latex')
        end
        
    case 2
        switch Scale
            case 'log'
                f = figure('Visible','off');
                a = axes;
                z = zoom(f);
                f.CreateFcn = @f_SizeChangedFcn;
                f.SizeChangedFcn = @f_SizeChangedFcn; %update axes after resize
                z.ActionPostCallback = @f_SizeChangedFcn; %update axes after zoom
                h=fsurf(log10(objFun),[lb,ub],'ShowContours','on'); % plot
                h.EdgeColor = 'none'; % delete lines
                f.Visible='on'; % trigger CreateFcn
                
                % axes
                a.TickLabelInterpreter = 'latex';
                xlabel(labX,'Interpreter','latex')
                ylabel(labY,'Interpreter','latex')
                zlabel('$T_{rms}$','Interpreter','latex')
                
                warning('zooming in/out with scrolling wheel will lead to wrong axes')
                
             
            case 'lin'
                % plot lin
                figure;
                a2 = axes;
                
                h=fsurf(objFun,[lb,ub],'ShowContours','on'); % plot
                h.EdgeColor = 'none'; % delete lines
                
                % axes
                a2.TickLabelInterpreter = 'latex';
                xlabel(labX,'Interpreter','latex')
                ylabel(labY,'Interpreter','latex')
                zlabel('$T_{rms}$','Interpreter','latex')
                set(a2,'ColorScale','lin')
        end
        
    otherwise
        error(['Plotting of objective function is only possible for '...
            'functions with 1 or 2 DOF'])
end

end

% function tickmarks
function f_SizeChangedFcn(~, ~)
a=gca;
a.ZAxis.TickLabelsMode='auto';
cOld=char(a.ZAxis.TickLabels);
n=size(cOld,1);
lNew=num2cell([repmat('$10^{',n,1), cOld, repmat('}$',n,1)],2);
a.ZAxis.TickLabels=lNew;
end

