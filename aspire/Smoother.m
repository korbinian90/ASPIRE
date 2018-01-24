classdef Smoother < handle
    %SMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        weightedSmoothing
        sigmaInVoxel
        smooth3d
        storage
    end
    
    methods (Abstract)
        smoothed = smoothImplementation(self, input, weight, factor);
    end
    
    methods
        function setup(self, sigmaInVoxel, weightedSmoothing, smooth3d, storage)
            self.sigmaInVoxel = sigmaInVoxel;
            self.weightedSmoothing = weightedSmoothing;
            self.smooth3d = smooth3d;
            self.storage = storage;
        end
        
        function smoothed = smooth(self, smoothed, weight, varargin)
            factor = 1;
            if nargin == 2
                weight = ones(size(smoothed));
            end
            if nargin == 4
                factor = varargin{1};
            end
            
            nChannels = size(smoothed, 5);
            for iCha = 1:nChannels
                    smoothed(:,:,:,iCha) = self.smoothImplementation(smoothed(:,:,:,iCha), weight, factor);
            end
        end
    end
    
end

