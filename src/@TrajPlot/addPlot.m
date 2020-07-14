function [] = addPlot(obj,sol,varargin)
obj.iPlot=obj.iPlot+1;

% label
if isempty(varargin)
    switch sol.input.sTrajType
        case {'trap','poly5'}
            label = sol.input.sTrajType;
        case {'poly','cheb','chebU'}
            label = strcat(sol.input.sTrajType,...
                num2str(sol.input.DOF+5));
        case {'spline'}
            label = strcat(sol.input.sTrajType,...
                num2str(sol.input.nPieces));
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
        q=sol(j).q/pi*180;
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
        br_Tm1=subs(Tm(i-1),t,breaks(i));
        br_Tm2=subs(Tm(i),t,breaks(i));
        plot([breaks(i) breaks(i)],[br_Tm1 br_Tm2],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
    end
    for i=1:nPieces
        fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',1.2,...
            'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
        br_Tm1=subs(Tm(i),t,breaks(i));
        br_Tm2=subs(Tm(i),t,breaks(i+1));
        plot([breaks(i) breaks(i+1)],[br_Tm1 br_Tm2],'.k'...
            ,'MarkerSize',14,'HandleVisibility','off');
    end
end

axes(obj.aTr)
xlim([sol(1).breaks(1) sol(end).breaks(end)]);

axes(obj.aTm)
xlim([sol(1).breaks(1) sol(end).breaks(end)]);

end