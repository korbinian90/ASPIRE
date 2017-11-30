classdef SmoothN < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight)
            if self.smooth3d
                if self.weightedSmoothing
                    smoothed = smoothn(input, weight, self.sigmaInVoxel);
                else
                    smoothed = smoothn(input, self.sigmaInVoxel);
                end
            else    
                smoothed = input;
                for iSlice = 1:size(input, 3)    
                    if self.weightedSmoothing
                        smoothed(:,:,iSlice) = smoothn(input(:,:,iSlice), weight, self.sigmaInVoxel);                   
                    else
                        smoothed(:,:,iSlice) = smoothn(input(:,:,iSlice), self.sigmaInVoxel);                   
                    end
                end
            end
               
        end

    end
    
end

