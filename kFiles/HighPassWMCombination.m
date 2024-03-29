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
            numIterativeSteps = 3;
            
            combined = combine@RootSumOfSquares(abs(image), []);
            self.storage.write(combined, 'rsos');
            
            firstEcho = combined(:,:,:,1);
            
            mask = stableMask(firstEcho);
            self.storage.write(mask, 'stableMask');
            
            lowPass = self.smoother.smooth(firstEcho, firstEcho);
            self.storage.write(lowPass, 'lowPass');
            
%             hp_combined = combined;
%             inhomogeneity = lowPass;
            for i = 1:numIterativeSteps
                hp_combined = firstEcho ./ lowPass;
                self.storage.write(hp_combined, sprintf('hp_combined_%d', i));
    
                wm_mask = BoxSegmenter.segment(hp_combined, ~mask);
                wm = firstEcho;
                wm(~wm_mask) = NaN;
%                 wm(wm > 2) = 2;
                self.storage.write(wm, sprintf('wm_%d', i));

                lowPass = self.smoother.smooth(wm, firstEcho);
                self.storage.write(lowPass, sprintf('lowPassWM_%d', i));
                
%                 inhomogeneity = inhomogeneity .* lowPass;
%                 self.storage.write(inhomogeneity, sprintf('inhomogeneity_%d', i));
            end
            
            % TODO: smooth inhomogeneity?
            for iEcho = 1:size(firstEcho, 4)
                combined(:,:,:,iEcho) = combined(:,:,:,iEcho) ./ lowPass;
            end
        end
    end
    
end

