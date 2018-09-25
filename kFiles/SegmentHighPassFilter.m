classdef SegmentHighPassFilter < BaseClass
    %LOWPASSCOMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    properties
       nanSmoother 
    end
    
    methods
        %override
        function setup(self, data)
            self.setup@BaseClass(data);
            self.storage.setSubdir('highPassFilter');

            self.nanSmoother = NanGaussianSmoother;
            self.nanSmoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
            self.smoother = GaussianBoxSmoother;
            self.smoother.setup(data.smoothingSigmaSizeInVoxel, 1, data.smooth3d, self.storage);
        end


        function filtered = filter(self, combined)
            lastStepSmoothingFactor = 0.5;
            smoothingFactor = sqrt(1 - lastStepSmoothingFactor^2);
            
            numIterativeSteps = 3;
            self.storage.write(abs(combined), 'rsos');
            
            firstEcho = abs(combined(:,:,:,1));
            
            mask = stableMask(firstEcho);
            self.storage.write(mask, 'stableMask');
            stableMean = mean(firstEcho(mask));
            
            lowPass = self.smoother.smooth(firstEcho, firstEcho, smoothingFactor);
            self.storage.write(lowPass, 'lowPass');
            
%             hp_combined = combined;
%             inhomogeneity = lowPass;
            for iStep = 1:numIterativeSteps
                hp_combined = firstEcho ./ lowPass;
                self.storage.write(hp_combined, sprintf('hp_combined_%d', iStep));
    
                wm_mask = BoxSegmenter.segment(hp_combined, mask, 15 + 10 * (iStep - 1)); % try to increase box size
                wm = firstEcho;
                wm(~wm_mask) = NaN;
%                 wm(wm > 2) = 2;
                self.storage.write(wm, sprintf('wm_%d', iStep));
                %TEST
%                 wm = nan_dilate(wm, 2);
%                 self.storage.write(wm, sprintf('wm_dilate_%d', iStep));

                lowPass = self.nanSmoother.smooth(wm, firstEcho, smoothingFactor); % try to increase sigma
                self.storage.write(lowPass, sprintf('lowPassWM_%d', iStep));
                
%                 inhomogeneity = inhomogeneity .* lowPass;
%                 self.storage.write(inhomogeneity, sprintf('inhomogeneity_%d', i));
                    % TODO: smooth inhomogeneity?
            end
%             lowPass = nan_dilate(lowPass, 5);
            stableThresh = stableMean / 4;
            lowPassMask = lowPass < stableThresh | isnan(lowPass) | lowPass > 10 * stableMean;
            lowPass(lowPassMask) = stableMean * 3;
            lowPassWeight = 1.2 - lowPassMask;
%             lowPass(lowPass < stableThres | isnan(lowPass)) = stableMean * 2;
%             lowPass(lowPass < stableThresh & lowPass ~= 0) = 2 * stableThresh - lowPass(lowPass < stableThresh & lowPass ~= 0);
            self.storage.write(lowPass, 'lowPassWM_Thresh');
%             lowPass = edgeFill(lowPass, lowPass > stableThresh, self.smoother.sigmaInVoxel * 3);
            lowPass = self.smoother.smooth(lowPass, lowPassWeight, lastStepSmoothingFactor);
            self.storage.write(lowPass, 'lowPassWM_Thresh_smooth');
%             for iSlice = 1:size(mask, 3)
%                 mask(:,:,iSlice) = imdilate(mask(:,:,iSlice), strel('square',3));
%                 mask(:,:,iSlice) = imerode(mask(:,:,iSlice), strel('disk',10));
%             end
            %lowPass(mask) = stableMean;
            filtered = zeros(size(combined));
            for iEcho = 1:size(firstEcho, 4)
                filtered(:,:,:,iEcho) = combined(:,:,:,iEcho) ./ lowPass;
            end
            
            self.storage.setSubdir('results');
            self.storage.write(abs(filtered), 'filtered_mag');
            self.storage.setSubdir('highPassFilter');
        end
    end
    
end

