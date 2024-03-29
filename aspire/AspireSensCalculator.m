classdef AspireSensCalculator < AspirePoCalculator
    %ASPIRESENSCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensMask
    end
    
    methods
        % override
        function setSens(~, ~)
        end
               
%         % override
%         function iterativeCorrection(self, compl)
%             if self.iterativeSteps
%                 compl = self.removePo(compl);
%                 combined = weightedCombinationAspire(compl, abs(self.po));
%                 phaseDiff = self.calculateCombinedDifference(compl);
%                 residual = combined(:,:,:,1) .* (phaseDiff ./ abs(phaseDiff));
%                 residual(~isfinite(residual)) = 0;
% 
%                 self.storage.write(compl(:,:,:,:,1), 'compl');
%                 self.storage.write(abs(compl(:,:,:,:,1)), 'abscompl');
%                 self.storage.write(residual, 'residualNaN');
%                 self.storage.write(angle(combined), 'combined');
%                 self.storage.write(phaseDiff, 'phaseDiff');
%                 % mag - phase ?? div - diff ??
%                 poTerm = zeros(size(residual));
%                 for iStep = 1:self.iterativeSteps
%                     residualSmooth = self.smoother.smooth(residual, abs(combined(:,:,:,1)));
%                     poTerm = poTerm + residualSmooth;
% 
%                     self.storage.write(residual, ['residual' num2str(iStep)]);
%                     self.storage.write(residualSmooth, ['residualSmooth' num2str(iStep)]);
%                     self.storage.write(poTerm, ['poTerm' num2str(iStep)]);
% 
%                     residual = residual - residualSmooth;
%                 end
%                 for iCha = 1:size(self.po, 4)
%                     self.po(:,:,:,iCha) = self.po(:,:,:,iCha) + residual;
%                 end
%             end
%         end
    
        %override
        function smoothPo(self, ~)
            sens_sum = sum(abs(self.po), 5);
            mask = stableMask(sens_sum); self.storage.write(mask, 'stableMask');
            
            weight = mask + 0.2;
            self.po = self.smoother.smooth(self.po, weight);
            
            % smooth mag            
            stableMean = mean(sens_sum(mask)) / size(self.po, 5) * 2;
            for iCha = 1:size(self.po, 5)
                mag = abs(self.po(:,:,:,1,iCha));
                magSensICha = mag;
                magSensICha(~mask) = stableMean;
                magSensICha = self.smoother.smooth(magSensICha, weight, 0.5);
                self.po(:,:,:,1,iCha) = self.po(:,:,:,1,iCha) ./ mag .* magSensICha;
            end
        end
        
        % override
        function po = calculatePo(self, compl)
            aspireEchoes = self.aspireEchoes;
            m = 1;
            storage = self.storage;
            
            if nargin == 1
                aspireEchoes = [1 2];
            end
            
            echoDiff = AspireSensCalculator.calculateCombinedDifference(compl(:,:,:,aspireEchoes,:));
            
            if nargin == 3
                echoDiff = echoDiff .^ m;
            end
            
            dim = size(compl);
            po = zeros([dim(1:3) 1 size(compl, 5)]);
            for iCha = 1:size(po, 5)
                po(:,:,:,1,iCha) = compl(:,:,:,aspireEchoes(1),iCha) .* echoDiff;
            end
            
%             po = abs(compl(:,:,:,1,:)) .* exp(1i * angle(po));
            storage.write(po, 'poBeforeEdgeFill');
            storage.write(real(po), 'realBeforeEdgeFill');
            storage.write(abs(po), 'absBeforeEdgeFill');
%             po = edgeFill(po, floor(2 * sigmaInVoxel));
%             po = edgeFill(po, floor(2 * sigmaInVoxel));
%             storage.write(po, 'poEdgeFill');
%             storage.write(real(po), 'realEdgeFill');
%             storage.write(abs(po), 'absEdgeFill');
        
            % set noise values to be
%             sens_sum = sum(abs(po), 5);
%             mask = stableMask(sens_sum);
%             stableMean = mean(sens_sum(mask)) / size(po, 5) * 2;
%             for iCha = 1:size(po, 5)
%                 poICha = po(:,:,:,1,iCha);
%                 poICha(~mask) = poICha(~mask) ./ abs(poICha(~mask)) * stableMean;
%                 po(:,:,:,1,iCha) = poICha;
%             end
%             storage.write(mask, 'mask');
%             storage.write(abs(po), 'absAfter');
            
%             self.sensMask = mask;
            self.po = po;
        end
        
    end
    methods (Static)
        % override
%         function po = calculateAspirePo(compl, aspireEchoes, m)
%             if nargin == 2
%                 m = 1;
%             end
%             po = calculateAspirePo@AspirePoCalculator(compl, aspireEchoes, m);
%             po = PoCalculator.removeMag(po);
%             mag = AspireSensCalculator.getMagAtTimeZero(compl(:,:,:,aspireEchoes,:), m);
%             po = mag .* po;
%         end
%         
%         function mag = getMagAtTimeZero(compl, m)
%             dim = size(compl);
%             mag = reshape(abs(compl(:,:,:,1,:)) .* (abs(compl(:,:,:,1,:)) ./ abs(compl(:,:,:,2,:))) .^ m, dim([1:3, 5]));
%             mag(~isfinite(mag)) = 0.1;
%         end
        

        function echoDiff = calculateCombinedDifference(compl)
            dim = size(compl);
            echoDiff = zeros(dim(1:3));
            weightSum = zeros(dim(1:3));
            for iCha = 1:size(compl, 5)
                mag = abs(compl(:,:,:,1,iCha));
                weightSum = weightSum + mag;
                echoDiff = echoDiff + mag .* (compl(:,:,:,1,iCha) ./ compl(:,:,:,2,iCha));
            end
            echoDiff = echoDiff ./ weightSum;
            echoDiff(~isfinite(echoDiff)) = 0;
        end
        
    end
    
end

