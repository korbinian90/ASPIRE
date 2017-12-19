classdef GaussianBoxSmootherEdge < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, factor)
            if ~self.weightedSmoothing
                weight = [];
            end
            sigma = self.sigmaInVoxel * factor;
            
            if self.smooth3d
                smoothed = weightedGaussianSmooth3d(input, sigma, weight);
            else
                smoothed = gaussianSmoothingWithInterpolation(input, sigma, weight);
            end
               
        end

        function smoothed = gaussianFilterWithInterpolation(input, sigma, weight)
            
        end
        
    end
    
end

