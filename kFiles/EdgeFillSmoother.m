classdef EdgeFillSmoother < GaussianBoxSmoother
    %EDGEFILLSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % override
        function smoothed = smoothImplementation(self, input, weight, factor)
            input = edgeFill(input, self.sigmaInVoxel * 2);
            self.storage.write(input, 'poEdgeFilled');
            self.storage.write(abs(input), 'absEdgeFilled');
            smoothed = smoothImplementation@GaussianBoxSmoother(self, input, weight, factor);
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
