classdef TrajPlot < handle
    %graph Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        f       % main figure  handle
        aTr     % axes with trajectory
        aTm     % axes with driving torque
        timeA   % start time
        timeB   % end time
        posA    % start position
        posB    % end position
        iPlot
        colorsUA
    end
    
    methods
        function obj = TrajPlot(input)
            obj.f = figure('Name','Trajectory Optimization'...
                ,'Renderer','painters');
            obj.timeA=input.timeA;
            obj.timeB=input.timeB;
            obj.posA=input.posA/pi*180;
            obj.posB=input.posB/pi*180;
            
            posLB = min(obj.posA,obj.posB);
            posUB = max(obj.posA,obj.posB);
            
            % latex
            set(0,'DefaultTextInterpreter','latex');
            set(0,'DefaultLegendInterpreter','latex');
            set(0,'DefaultAxesTickLabelInterpreter','latex');
            
            % colors
            obj.iPlot=0;
            obj.colorsUA = [0, 68, 102;
                136, 017, 051;
                187, 204, 204;
                136, 153, 153;
                051, 153, 204;
                221, 153, 017;
                170, 170 ,000]./255;
            
            obj.aTr=subplot(2,1,1);
            xlabel('$t \, [s]$')
            ylabel('$\theta(t) \, [^{\circ}]$')
            dx=0.03*(obj.timeB-obj.timeA);
            dy=0.03*(posUB-posLB);
            xlim([obj.timeA-dx,obj.timeB+dx]);
            ylim([posLB-dy,posUB+dy])
            legend('Location','northeastoutside');
            hold on
            %plot([obj.timeA,obj.timeB],[obj.posA,obj.posB],'.k'...
            %,'MarkerSize',15,'HandleVisibility','off')
            
            obj.aTm=subplot(2,1,2);
            xlabel('$t \, [s]$')
            ylabel('$T_m(t) \, [Nm]$')
            obj.aTm.TickLabelInterpreter='latex';
            xlim([obj.timeA-dx,obj.timeB+dx]);
            lgdTm=legend('Location','northeastoutside','Visible','off');
            lgdTm.Visible='off';
            hold on
            yline(0,'k','LineWidth',0.1,'HandleVisibility','off');
        end
        
        function [] = addPlot(obj,TrajOpt,varargin)
            obj.iPlot=obj.iPlot+1;
            
            if isa(TrajOpt,'TrajOpt')
                q = TrajOpt.res.q/pi*180;
                Tm = TrajOpt.res.Tm;
                breaks = TrajOpt.res.breaks;
                nPieces = TrajOpt.input.nPieces;
                
                syms t
            else
                t=TrajOpt.t;
                q=TrajOpt.q/pi*180;
                Tm=TrajOpt.Tm;
            end
            
            % label
            if isempty(varargin)
                label = strcat(TrajOpt.input.sTrajType,...
                    num2str(TrajOpt.input.DOF));
            else
                label=varargin{1};
            end
            
            axes(obj.aTr)
            hold on
            if isa(TrajOpt,'TrajOpt')
                fplot(q(1),[breaks(1) breaks(2)],'LineWidth',2,...
                        'Color',obj.colorsUA(obj.iPlot,:),'DisplayName',num2str(label));
                for i=1:nPieces
                    fplot(q(i),[breaks(i) breaks(i+1)],'LineWidth',2,...
                        'Color',obj.colorsUA(obj.iPlot,:),'HandleVisibility','off');
                    br_q1=subs(q(i),t,breaks(i));
                    br_q2=subs(q(i),t,breaks(i+1));
                    plot([breaks(i) breaks(i+1)],[br_q1 br_q2],'.k'...
                        ,'MarkerSize',14,'HandleVisibility','off');
                end
            else
                plot(t,q,'LineWidth',2,'Color',...
                    obj.colorsUA(obj.iPlot,:),'DisplayName',num2str(label));
            end
            
            axes(obj.aTm)
            hold on
            if isa(TrajOpt,'TrajOpt')
                for i=2:nPieces % add connecting lines (discontinous torque)
                    br_Tm1=subs(Tm(i-1),t,breaks(i));
                    br_Tm2=subs(Tm(i),t,breaks(i));
                    plot([breaks(i) breaks(i)],[br_Tm1 br_Tm2],'LineWidth',2,...
                        'Color',obj.colorsUA(obj.iPlot,:),'HandleVisibility','off');
                end
                for i=1:nPieces
                    fplot(Tm(i),[breaks(i) breaks(i+1)],'LineWidth',2,...
                        'Color',obj.colorsUA(obj.iPlot,:),'HandleVisibility','off');
                    br_Tm1=subs(Tm(i),t,breaks(i));
                    br_Tm2=subs(Tm(i),t,breaks(i+1));
                    plot([breaks(i) breaks(i+1)],[br_Tm1 br_Tm2],'.k'...
                        ,'MarkerSize',14,'HandleVisibility','off');
                end
            else
                plot(t,Tm,'LineWidth',2,'Color',...
                    obj.colorsUA(obj.iPlot,:),'DisplayName',num2str(label)...
                    ,'HandleVisibility','off');
            end
            
        end
        function [] = removeWhitespace(obj)
            ax=obj.aTr;
            outerpos = ax.OuterPosition;
            ti = ax.TightInset;
            left = outerpos(1) + ti(1);
            bottom = outerpos(2) + ti(2);
            ax_width = outerpos(3) - ti(1) - ti(3);
            ax_height = outerpos(4) - ti(2) - ti(4);
            ax.Position = [left bottom ax_width ax_height];
            
            ax=obj.aTm;
            outerpos = ax.OuterPosition;
            ti = ax.TightInset;
            left = outerpos(1) + ti(1);
            bottom = outerpos(2) + ti(2);
            ax_width = outerpos(3) - ti(1) - ti(3);
            ax_height = outerpos(4) - ti(2) - ti(4);
            ax.Position = [left bottom ax_width ax_height];
        end
    end
end

