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
        
        
    end
end

