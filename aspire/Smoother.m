classdef Smoother < handle
    %SMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        weightedSmoothing
        sigmaInVoxel
        smooth3d
    end
    
    methods (Abstract)
        smoothed = smoothImplementation(self, input, weight, factor);
    end
    
    methods
        function setup(self, sigmaInVoxel, weightedSmoothing, smooth3d)
            self.sigmaInVoxel = sigmaInVoxel;
            self.weightedSmoothing = weightedSmoothing;
            self.smooth3d = smooth3d;
        end
        
        function smoothed = smooth(self, smoothed, weight, varargin)
            if self.sigmaInVoxel > 0
                factor = 1;
                if nargin == 4
                    factor = varargin{1};
                end

                nChannels = size(smoothed, 4);
                for iCha = 1:nChannels
                        smoothed(:,:,:,iCha) = self.smoothImplementation(smoothed(:,:,:,iCha), weight, factor);
                end
            end
        end
    end
    
end

