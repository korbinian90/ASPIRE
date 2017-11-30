classdef SmoothN < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, factor)
            s = self.sigmaInVoxel * factor;
            
            if self.smooth3d
                if self.weightedSmoothing
                    smoothed = smoothn(input, weight, s);
                else
                    smoothed = smoothn(input, s);
                end
            else    
                smoothed = input;
                for iSlice = 1:size(input, 3)    
                    if self.weightedSmoothing
                        smoothed(:,:,iSlice) = smoothn(input(:,:,iSlice), weight, s);                   
                    else
                        smoothed(:,:,iSlice) = smoothn(input(:,:,iSlice), s);                   
                    end
                end
            end
               
        end

    end
    
end

