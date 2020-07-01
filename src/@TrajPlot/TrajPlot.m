classdef TrajPlot < handle
    %graph Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        f       % main figure  handle
        fig
        aTr     % axes with trajectory
        aTm     % axes with driving torque
        lgdTr   % legend trajectory
        lgdTm   % legend driving torque
        timeA   % start time
        timeB   % end time
        posA    % start position
        posB    % end position
        iPlot
        colorMap
    end
    
    methods
        function obj = graph(problem)
            obj.f = figure('Name','Trajectory Optimization'...
                ,'Renderer','painters');
            obj.timeA=problem.timeA;
            obj.timeB=problem.timeB;
            obj.posA=problem.posA/pi*180;
            obj.posB=problem.posB/pi*180;
            
            posLB = min(obj.posA,obj.posB);
            posUB = max(obj.posA,obj.posB);
            
            % latex
            set(0,'DefaultTextInterpreter','latex');
            set(0,'DefaultLegendInterpreter','latex');
            set(0,'DefaultAxesTickLabelInterpreter','latex');
            
            % colors
            obj.iPlot=0;
            obj.colorMap=[0, 0.4470, 0.7410;...
                0.8500, 0.3250, 0.0980;...
                0.9290, 0.6940, 0.1250;...
                0.4940, 0.1840, 0.5560;...
                0.4660, 0.6740, 0.1880;...
                0.3010, 0.7450, 0.9330;...
                0.6350, 0.0780, 0.1840];
            
            obj.aTr=subplot(2,1,1);
            xlabel('$t \, [s]$')
            ylabel('$\theta(t) \, [^{\circ}]$')
            dx=0.03*(obj.timeB-obj.timeA);
            dy=0.03*(posUB-posLB);
            xlim([obj.timeA-dx,obj.timeB+dx]);
            %ylim([posLB-dy,posUB+dy])
            obj.lgdTr=legend('Location','northeastoutside');
            hold on
            plot([obj.timeA,obj.timeB],[obj.posA,obj.posB],'.k','MarkerSize',15,'HandleVisibility','off')
            
            obj.aTm=subplot(2,1,2);
            xlabel('$t \, [s]$')
            ylabel('$T_m(t) \, [Nm]$')
            obj.aTm.TickLabelInterpreter='latex';
            xlim([obj.timeA-dx,obj.timeB+dx]);
            obj.lgdTm=legend('Location','northeastoutside');
            obj.lgdTm.Visible='off';
            hold on
            yline(0,'k','LineWidth',0.1,'HandleVisibility','off');
        end
        
        function [] = addPlot(obj,input,label)
            obj.iPlot=obj.iPlot+1;
            
            if isa(input,'TrajectoryOptimisation')
                q=input.res.qd1/pi*180;
                Tm=input.res.Tm;
                nInt = input.problem.traj.nInt;
                br = input.traj.breakPoints;
                syms t
            else
                t=input.t;
                q=input.qd1/pi*180;
                Tm=input.Tm;
                
            end
            
            axes(obj.aTr)
            hold on
            if isa(input,'TrajectoryOptimisation')
                fplot(q(1),[br(1) br(2)],'LineWidth',2,'Color',...
                    obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
                
                for i=2:nInt
                    fplot(q(i),[br(i) br(i+1)],'LineWidth',2,'Color',...
                        obj.colorMap(obj.iPlot,:),'HandleVisibility','off');
                    p=subs(q(i),t,br(i));
                    plot(br(i),p,'.k','MarkerSize',10,'HandleVisibility','off');
                end
            else
                plot(t,q,'LineWidth',2,'Color',...
                    obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
            end
            
            axes(obj.aTm)
            hold on
            if isa(input,'TrajectoryOptimisation')
                fplot(Tm(1),[br(1) br(2)],'LineWidth',2,'Color',...
                    obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
                for i=2:nInt
                    fplot(Tm(i),[br(i) br(i+1)],'LineWidth',2,'Color',...
                        obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
                    p=subs(Tm(i),t,br(i));
                    plot(br(i),p,'.k','MarkerSize',10,'HandleVisibility','off');
                end
            else
                plot(t,Tm,'LineWidth',2,'Color',...
                    obj.colorMap(obj.iPlot,:),'DisplayName',num2str(label));
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

