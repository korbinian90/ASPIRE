classdef NanGaussianSmoother < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, factor)
            sigma = self.sigmaInVoxel * factor;
            
            if self.smooth3d
%                 smoothed = weightedGaussianSmooth3d(input, sigma, weight);
            else
                threshold = 0.25;
%                 weight = sum(weight, 5);
                % TODO slicewise for 3d
                mean_mask = weight >= mean(weight(:));
                mean_mask = weight >= mean(weight(mean_mask));
                mean_mask = weight >= mean(weight(mean_mask));
                mask = weight < threshold * mean(weight(mean_mask));
                self.storage.write(single(mask), 'mask');
                
                smoothed = nanGaussianSmooth(input, sigma, mask);
            end
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