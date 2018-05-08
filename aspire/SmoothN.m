classdef SmoothN < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, factor)
            s = 1 * min(self.sigmaInVoxel); % confirmed with visual test
            d = 1 ./ (self.sigmaInVoxel * factor);
            
            OPTIONS.TolZ = 0.01;
            
            if self.smooth3d
                OPTIONS.Spacing = d;
                if self.weightedSmoothing
                    smoothed = smoothn(input, weight, s, OPTIONS);
                else
                    smoothed = smoothn(input, s, OPTIONS);
                end
            else
                OPTIONS.Spacing = d(1:2);
                smoothed = input;
                for iSlice = 1:size(input, 3)
                    if self.weightedSmoothing
                        smoothed(:,:,iSlice) = smoothn(input(:,:,iSlice), weight(:,:,iSlice), s, OPTIONS);                   
                    else
                        smoothed(:,:,iSlice) = smoothn(input(:,:,iSlice), s, OPTIONS);                   
                    end
                end
            end
               
        end

    end
    
end

