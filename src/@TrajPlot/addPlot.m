function [] = addPlot(obj,TrajOpt,varargin)
            obj.iPlot=obj.iPlot+1;
            
            if isa(TrajOpt,'TrajOpt')
                syms t
                q = TrajOpt.res.q/pi*180;
                Tm = TrajOpt.res.Tm;
                breaks = TrajOpt.res.breaks;
                nPieces = TrajOpt.input.nPieces;
            else
                t=TrajOpt.t;
                q=TrajOpt.q/pi*180;
                Tm=TrajOpt.Tm;
            end
            
            % label
            if isempty(varargin)
                switch TrajOpt.input.sTrajType
                    case {'trap','poly5'}
                        label = TrajOpt.input.sTrajType;
                    case {'poly','cheb','chebU','spline','custom'}
                        label = strcat(TrajOpt.input.sTrajType,...
                    num2str(TrajOpt.input.DOF));
                end
            else
                label=varargin{1};
            end
            
            axes(obj.aTr)
            hold on
            if isa(TrajOpt,'TrajOpt')
                fplot(q(1),[breaks(1) breaks(2)],'LineWidth',2,...
                        'Color',obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
                for i=1:nPieces
                    fplot(q(i),[breaks(i) breaks(i+1)],'LineWidth',2,...
                        'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
                    br_q1=subs(q(i),t,breaks(i));
                    br_q2=subs(q(i),t,breaks(i+1));
                    plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
                        ,'MarkerSize',14,'HandleVisibility','off');
                end
            else
                plot(t,q,'LineWidth',2,'Color',...
                    obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
            end
            
            axes(obj.aTm)
            hold on
            if isa(TrajOpt,'TrajOpt')
                for i=2:nPieces % add connecting lines (discontinous torque)
                    br_Tm1=subs(Tm(i-1),t,breaks(i));
                    br_Tm2=subs(Tm(i),t,breaks(i));
                    plot([breaks(i) breaks(i)],[br_Tm1 br_Tm2],'LineWidth',2,...
                        'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
                end
                for i=1:nPieces
                    fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',2,...
                        'Color',obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
                    br_Tm1=subs(Tm(i),t,breaks(i));
                    br_Tm2=subs(Tm(i),t,breaks(i+1));
                    plot([breaks(i) breaks(i+1)],[br_Tm1 br_Tm2],'.k'...
                        ,'MarkerSize',14,'HandleVisibility','off');
                end
            else
                plot(t,Tm,'LineWidth',2,'Color',...
                    obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label)...
                    ,'HandleVisibility','off');
            end
            
        end