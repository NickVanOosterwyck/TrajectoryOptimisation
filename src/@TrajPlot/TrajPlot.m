classdef TrajPlot < handle
    %graph Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        f       % main figure  handle
        aTr     % axes with trajectory
        aSp     % axes with speed
        aAc     % axes with acceleration
        aTm     % axes with driving torque
        timeA   % start time
        timeB   % end time
        posA    % start position
        posB    % end position
        iPlot
        colorMap
    end
    
    methods
        function obj = TrajPlot(varargin)
            obj.f = figure('Name','Trajectory Optimization'...
                ,'Renderer','painters');
%             obj.timeA=input.timeA;
%             obj.timeB=input.timeB;
%             obj.posA=input.posA/pi*180;
%             obj.posB=input.posB/pi*180;
%             
%             posLB = min(obj.posA,obj.posB);
%             posUB = max(obj.posA,obj.posB);

            if isempty(varargin)
                location = 'northwest';
            else
                location = varargin{1};
            end
            
            % latex
            set(0,'DefaultTextInterpreter','latex');
            set(0,'DefaultLegendInterpreter','latex');
            set(0,'DefaultAxesTickLabelInterpreter','latex');
            
            % colors
            obj.iPlot=0;
            colorsUA = [0, 68, 102;
                136, 017, 051;
                051, 153, 204;
                221, 153, 017;
                170, 170 ,000
                187, 204, 204;]./255;
            colorsMatlab = [0, 0.4470, 0.7410;
                0.8500, 0.3250, 0.0980;
                0.9290, 0.6940, 0.1250;
                0.4940, 0.1840, 0.5560;
                0.4660, 0.6740, 0.1880;
                0.3010, 0.7450, 0.9330;
                0.6350, 0.0780, 0.1840];
            obj.colorMap = [colorsUA;colorsMatlab];
            
            obj.aTr=subplot(4,1,1);
            xlabel('$t \, [s]$')
            ylabel('$\theta \, [^{\circ}]$')
%             dx=0.03*(obj.timeB-obj.timeA);
%             dy=0.03*(posUB-posLB);
%             xlim([obj.timeA-dx,obj.timeB+dx]);
%             ylim([posLB-dy,posUB+dy])
            legend('Location',location);
            
            obj.aSp=subplot(4,1,2);
            xlabel('$t \, [s]$')
            ylabel('$\dot{\theta} \, [^{\circ}/s]$')
%             dx=0.03*(obj.timeB-obj.timeA);
%             dy=0.03*(posUB-posLB);
%             xlim([obj.timeA-dx,obj.timeB+dx]);
%             ylim([posLB-dy,posUB+dy])
            lgd = legend('Location',location);
            lgd.Visible = 'off';
            
            obj.aAc=subplot(4,1,3);
            xlabel('$t \, [s]$')
            ylabel('$\ddot{\theta} \, [^{\circ}/s^2]$')
%             dx=0.03*(obj.timeB-obj.timeA);
%             dy=0.03*(posUB-posLB);
%             xlim([obj.timeA-dx,obj.timeB+dx]);
%             ylim([posLB-dy,posUB+dy])
            lgd = legend('Location',location);
            lgd.Visible = 'off';
            
            obj.aTm=subplot(4,1,4);
            xlabel('$t \, [s]$')
            ylabel('$T_m \, [Nm]$')
            obj.aTm.TickLabelInterpreter='latex';
%             xlim([obj.timeA-dx,obj.timeB+dx]);
            lgd = legend('Location',location);
            lgd.Visible = 'off';
            hold on
            yline(0,'k','LineWidth',0.1,'HandleVisibility','off');
        end  
    end
end

