classdef GaussianBoxSmoother < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight)
            if ~self.weightedSmoothing
                weight = [];
            end
            if self.smooth3d
                smoothed = weightedGaussianSmooth3d(input, self.sigmaInVoxel, weight);
            else
                smoothed = weightedGaussianSmooth(input, self.sigmaInVoxel, weight);
            end
               
        end

    end
    
end

