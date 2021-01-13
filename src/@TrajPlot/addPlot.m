function [] = addPlot(obj,sol,varargin)
obj.iPlot=obj.iPlot+1;

% label
if isempty(varargin)
    switch sol(1).input.sTrajType
        case {'trap','poly5'}
            label = sol(1).input.sTrajType;
        case {'poly','cheb','chebU'}
            label = strcat(sol(1).input.sTrajType,...
                num2str(sol(1).input.DOF+5));
        case {'spline'}
            label = strcat(sol(1).input.sTrajType,...
                num2str(sol(1).input.nPieces));
        case {'custom','dis'}
            label = strcat('traj',num2str(obj.iPlot));
    end
else
    label=varargin{1};
end

syms t
axes(obj.aTr)
for j = 1:length(sol)
    t = sol(j).res.t;
    q = sol(j).res.q./pi.*180;
    breaks = sol(j).res.breaks;
    nPieces = sol(j).input.nPieces;
    hold on
    for i=1:nPieces
        switch sol(j).input.sTrajType
            case 'dis'
                h = plot(t,q,'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                plot([t(1) t(end)],[q(1) q(end)],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
            otherwise
                h = fplot(q(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                br_q1=subs(q(i),t,breaks(i));
                br_q2=subs(q(i),t,breaks(i+1));
                plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
        end
    end
end
h.HandleVisibility='on'; % add last plot to legend

axes(obj.aSp)
for j = 1:length(sol)
    t = sol(j).res.t;
    qd1 = sol(j).res.qd1./pi.*180;
    breaks = sol(j).res.breaks;
    nPieces = sol(j).input.nPieces;
    hold on
    for i=1:nPieces
        switch sol(j).input.sTrajType
            case 'dis'
                plot(t,qd1,'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                plot([t(1) t(end)],[qd1(1) qd1(end)],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
            otherwise
                fplot(qd1(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                br_q1=subs(qd1(i),t,breaks(i));
                br_q2=subs(qd1(i),t,breaks(i+1));
                plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
        end
    end
end

axes(obj.aAc)
for j = 1:length(sol)
    t = sol(j).res.t;
    qd2 = sol(j).res.qd2./pi.*180;
    breaks = sol(j).res.breaks;
    nPieces = sol(j).input.nPieces;
    hold on
    for i=1:nPieces
        switch sol(j).input.sTrajType
            case 'dis'
                plot(t,qd2,'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                plot([t(1) t(end)],[qd2(1) qd2(end)],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
            otherwise
                fplot(qd2(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                br_q1=subs(qd2(i),t,breaks(i));
                br_q2=subs(qd2(i),t,breaks(i+1));
                plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
        end
    end
end

axes(obj.aTm)
for j = 1:length(sol)
    t = sol(j).res.t;
    Tm = sol(j).res.Tm;
    breaks = sol(j).res.breaks;
    nPieces = sol(j).input.nPieces;
    hold on
    for i=1:nPieces
        switch sol(j).input.sTrajType
            case 'dis'
                plot(t,Tm,'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                plot([t(1) t(end)],[Tm(1) Tm(end)],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
            otherwise
                fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
                    'Color',obj.colorMap(obj.iPlot,:),'DisplayName',...
                    num2str(label),'HandleVisibility','off');
                br_q1=subs(Tm(i),t,breaks(i));
                br_q2=subs(Tm(i),t,breaks(i+1));
                plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
                    ,'MarkerSize',14,'HandleVisibility','off');
        end
    end
end

% set axis
if j>1
    axes(obj.aTr)
    xlim([sol(1).res.breaks(1) sol(end).res.breaks(end)]);
    
    axes(obj.aSp)
    xlim([sol(1).res.breaks(1) sol(end).res.breaks(end)]);
    
    axes(obj.aAc)
    xlim([sol(1).res.breaks(1) sol(end).res.breaks(end)]);
    
    axes(obj.aTm)
    xlim([sol(1).res.breaks(1) sol(end).res.breaks(end)]);
end


end