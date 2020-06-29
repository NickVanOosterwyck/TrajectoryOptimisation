classdef TrajOpt < handle
    properties (SetAccess = protected)
        input % validated input
        traj % trajectory definition
        prop % properties
        fit % fitness function
        sol % solution
        res % result 
    end
    
    methods
        function obj = TrajOpt(input)
            obj.input = obj.parseInput(input);
        end
        
        function [] = defineFitnessFunc(obj)
            if isempty(obj.traj)
                obj.defineTrajectory();
            end
            if isempty(obj.prop)
                obj.defineProperties();
            end
            obj.fit = createFit(obj.input,obj.traj,obj.prop);
        end
        
        function [] = optimiseFitnessFunc(obj)
            if isempty(obj.fit)
                obj.defineFitnessFunc();
            end
            obj.sol = optimizeTrajectory(obj.input,obj.traj,obj.fit);
        end
        
        function [] = optimiseTrajectory(obj)
            if isempty(obj.fit)
                obj.defineFitnessFunc();
            end
            obj.sol = optimizeTrajectory(obj.input,obj.traj,obj.fit);
            obj.res = evalSol(obj.input,obj.traj,obj.prop,obj.fit,obj.sol);
        end
        
    end
end

