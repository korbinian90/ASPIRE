classdef HighPassCombination < RootSumOfSquares
    %LOWPASSCOMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        smoother
    end
    
    methods
	%override
	function setup(self, data)
            setup@Combination(self, data);
            self.smoother = NanGaussianSmoother();
            self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
        end


        function combined = combine(self, image, sens)
            combined = combine@RootSumOfSquares(image, []);
            self.storage.write(combined, 'rsos');
            lowPass = self.smoother.smooth(combined, sens);
            self.storage.write(lowPass, 'lowPass');
            combined = combined - lowPass;
        end
    end
    
end

