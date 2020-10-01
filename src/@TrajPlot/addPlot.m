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
        case {'custom'}
            label = strcat('traj',obj.iPlot);
    end
else
    label=varargin{1};
end

syms t
axes(obj.aTr)
for j = 1:length(sol)
    if isa(sol(j),'TrajOpt')
        q = sol(j).res.q/pi*180;
        breaks = sol(j).res.breaks;
        nPieces = sol(j).input.nPieces;
    else
        q=sol(j).q./pi.*180;
        breaks = sol(j).breaks;
        nPieces = sol(j).nPieces;
    end
    
    hold on
    if j==1
        fplot(q(1),[breaks(1) breaks(2)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
    else
        fplot(q(1),[breaks(1) breaks(2)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
    end
    for i=1:nPieces
        fplot(q(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
        br_q1=subs(q(i),t,breaks(i));
        br_q2=subs(q(i),t,breaks(i+1));
        plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
            ,'MarkerSize',14,'HandleVisibility','off');
    end
end

axes(obj.aSp)
for j = 1:length(sol)
    if isa(sol(j),'TrajOpt')
        qd1 = sol(j).res.qd1/pi*180;
        breaks = sol(j).res.breaks;
        nPieces = sol(j).input.nPieces;
    else
        qd1=sol(j).qd1./pi.*180;
        breaks = sol(j).breaks;
        nPieces = sol(j).nPieces;
    end
    
    hold on
    for i=1:nPieces
        fplot(qd1(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
        br_q1=subs(qd1(i),t,breaks(i));
        br_q2=subs(qd1(i),t,breaks(i+1));
        plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
            ,'MarkerSize',14,'HandleVisibility','off');
    end
end

axes(obj.aAc)
for j = 1:length(sol)
    if isa(sol(j),'TrajOpt')
        qd2 = sol(j).res.qd2/pi*180;
        breaks = sol(j).res.breaks;
        nPieces = sol(j).input.nPieces;
    else
        qd2=sol(j).qd2./pi.*180;
        breaks = sol(j).breaks;
        nPieces = sol(j).nPieces;
    end
    
    hold on
    for i=2:nPieces % add connecting lines (discontinous acceleration)
        br_1=subs(qd2(i-1),t,breaks(i));
        br_2=subs(qd2(i),t,breaks(i));
        plot([breaks(i) breaks(i)],[br_1 br_2],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
    end
    for i=1:nPieces
        fplot(qd2(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
        br_q1=subs(qd2(i),t,breaks(i));
        br_q2=subs(qd2(i),t,breaks(i+1));
        plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
            ,'MarkerSize',14,'HandleVisibility','off');
    end
end

axes(obj.aTm)
for j = 1:length(sol)
    if isa(sol(j),'TrajOpt')
        Tm = sol(j).res.Tm;
        breaks = sol(j).res.breaks;
        nPieces = sol(j).input.nPieces;
    else
        Tm = sol(j).Tm;
        breaks = sol(j).breaks;
        nPieces = sol(j).nPieces;
    end
    
    hold on
    for i=2:nPieces % add connecting lines (discontinous torque)
        br_1=subs(Tm(i-1),t,breaks(i));
        br_2=subs(Tm(i),t,breaks(i));
        plot([breaks(i) breaks(i)],[br_1 br_2],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
    end
    for i=1:nPieces
        fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
        br_1=subs(Tm(i),t,breaks(i));
        br_2=subs(Tm(i),t,breaks(i+1));
        plot([breaks(i) breaks(i+1)],[br_1 br_2],'.k'...
            ,'MarkerSize',14,'HandleVisibility','off');
    end
end

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