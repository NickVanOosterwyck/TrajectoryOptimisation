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
        function optimizeTrajectory(obj)
            obj.optimizeFitness();
            obj.parseSolution();
        end
    end
end

