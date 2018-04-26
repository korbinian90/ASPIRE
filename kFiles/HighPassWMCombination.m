classdef HighPassWMCombination < RootSumOfSquares
    %LOWPASSCOMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        smoother
    end
    
    methods
	%override
	function setup(self, data)
            setup@Combination(self, data);
            self.smoother = SmoothN;
            self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
        end


        function combined = combine(self, image, sens)
            combined = combine@RootSumOfSquares(abs(image), []);
            self.storage.write(combined, 'rsos');
            
            lowPass = self.smoother.smooth(combined, combined);
            self.storage.write(lowPass, 'lowPass');
            
            hp_combined = combined ./ lowPass;
            self.storage.write(hp_combined, 'hp_combined');
            
            mask = stableMask(combined);
            self.storage.write(mask, 'stableMask');
            
            wm_mask = BoxSegmenter.segment(combined, ~mask);
            wm = hp_combined;
            wm(~wm_mask) = NaN;
            wm(wm > 2) = 2;
            self.storage.write(wm, 'wm');
            
            lowPass = self.smoother.smooth(wm, combined);
            self.storage.write(lowPass, 'lowPassWM');
            combined = combined ./ lowPass;
            
            % TODO: make iterative loop
            
        end
    end
    
end

