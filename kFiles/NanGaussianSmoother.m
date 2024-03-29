classdef NanGaussianSmoother < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, factor)
            sigma = self.sigmaInVoxel * factor;

            mask = stableMask(weight);
            
            self.storage.write(single(mask), 'mask');
            self.storage.write(weight, 'weight');
            
            if self.smooth3d
                smoothed = nanGaussianSmooth3d(input, sigma, mask);
            else
                smoothed = nanGaussianSmooth(input, sigma, mask);
            end
%             smoothed(~isfinite(smoothed)) = 0;
        end
        
        % override
        function smoothed = smooth(self, smoothed, weight, varargin)
            factor = 1;
            if nargin == 2
                weight = ones(size(smoothed));
            end
            if nargin == 4
                factor = varargin{1};
            end
            
            smoothed = self.smoothImplementation(smoothed, weight, factor);
        end
    end
    
end
