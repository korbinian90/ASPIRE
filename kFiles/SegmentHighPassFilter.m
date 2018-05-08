classdef SegmentHighPassFilter < BaseClass
    %LOWPASSCOMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        %override
        function setup(self, data)
            self.setup@BaseClass(data);
            self.storage.setSubdir('highPassFilter');
            self.smoother = SmoothN;
            self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
        end


        function filtered = filter(self, combined)
            numIterativeSteps = 3;
            self.storage.write(abs(combined), 'rsos');
            
            firstEcho = abs(combined(:,:,:,1));
            
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
            filtered = zeros(size(combined));
            for iEcho = 1:size(firstEcho, 4)
                filtered(:,:,:,iEcho) = combined(:,:,:,iEcho) ./ lowPass;
            end
            
            self.storage.setSubdir('results');
            self.storage.write(filtered, 'filtered_mag');
            self.storage.setSubdir('highPassFilter');
        end
    end
    
end

