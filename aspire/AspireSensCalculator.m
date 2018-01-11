classdef AspireSensCalculator < AspirePoCalculator
    %ASPIRESENSCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       % override
       function setSens(~, ~)
       end
               
        % override
        function iterativeCorrection(self, compl)
            if self.iterativeSteps
                compl = self.removePo(compl);
                combined = weightedCombinationAspire(compl, abs(self.po));
                phaseDiff = self.calculateCombinedDifference(compl);
                residual = combined(:,:,:,1) .* (phaseDiff ./ abs(phaseDiff));
                residual(~isfinite(residual)) = 0;

                self.storage.write(compl(:,:,:,:,1), 'compl');
                self.storage.write(abs(compl(:,:,:,:,1)), 'abscompl');
                self.storage.write(residual, 'residualNaN');
                self.storage.write(angle(combined), 'combined');
                self.storage.write(phaseDiff, 'phaseDiff');
                % mag - phase ?? div - diff ??
                poTerm = zeros(size(residual));
                for iStep = 1:self.iterativeSteps
                    residualSmooth = self.smoother.smooth(residual, abs(combined(:,:,:,1)));
                    poTerm = poTerm + residualSmooth;

                    self.storage.write(residual, ['residual' num2str(iStep)]);
                    self.storage.write(residualSmooth, ['residualSmooth' num2str(iStep)]);
                    self.storage.write(poTerm, ['poTerm' num2str(iStep)]);

                    residual = residual - residualSmooth;
                end
                for iCha = 1:size(self.po, 4)
                    self.po(:,:,:,iCha) = self.po(:,:,:,iCha) + residual;
                end
            end
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
        
        % override
        function po = calculateAspirePo(compl, aspireEchoes, m)
            if nargin == 1
                aspireEchoes = [1 2];
            end
            
            echoDiff = AspireSensCalculator.calculateCombinedDifference(compl(:,:,:,aspireEchoes,:));
            
            if nargin == 3
                echoDiff = echoDiff .^ m;
            end
            
            dim = size(compl);
            po = zeros([dim(1:3) dim(5)]);
            for iCha = 1:size(po, 4)
                po(:,:,:,iCha) = compl(:,:,:,aspireEchoes(1),iCha) .* echoDiff;
            end
        end
        
        function echoDiff = calculateCombinedDifference(compl)
            dim = size(compl);
            echoDiff = zeros(dim(1:3));
            weightSum = zeros(dim(1:3));
            for iCha = 1:size(compl, 5)
                weight = abs(compl(:,:,:,1,iCha));
                weightSum = weightSum + weight;
                echoDiff = echoDiff + weight .* (compl(:,:,:,1,iCha) ./ compl(:,:,:,2,iCha));
            end
            echoDiff = echoDiff ./ weightSum;
            echoDiff(~isfinite(echoDiff)) = 0;
        end
        
    end
    
end

