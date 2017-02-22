classdef VrcPoCalculator < PoCalculator
    
properties
    TEs
    fovReductionFactor
end

methods
    % override
    function setup(self, data)
        setup@PoCalculator(self, data); % call super-method
        self.TEs = data.TEs;
        self.fovReductionFactor = 4;
    end
    % override
    function calculatePo(self, compl)
        
        vrcCoil = self.phaseMatchingOfChannelsSeperately(squeeze(compl(:,:,:,1,:)));
        
        self.po = self.subtractFromEcho(compl, vrcCoil, 1);
        
        self.storage.write(vrcCoil, 'vrcCoil');
        
    end
   
end

methods (Access = private)
    
    function vrcCoil = phaseMatchingOfChannelsSeperately(self, compl)
        corrected = compl;
        for iCha = 1:size(compl,4)
            centerPhase = self.getCenterPhase(corrected(:,:,:,iCha));
            corrected(:,:,:,iCha) = corrected(:,:,:,iCha) * conj(centerPhase);
        end
        vrcCoil = weightedCombination(corrected, abs(corrected));
    end
    
    function centerPhase = getCenterPhase(self, compl)
        xRange = self.getRange(size(compl, 1));
        yRange = self.getRange(size(compl, 2));
        zRange = self.getRange(size(compl, 3));
        smallFov = compl(xRange, yRange, zRange);
        
        mag = abs(smallFov);
        [~,index] = max(mag(:));
        [x, y, z] = ind2sub(size(smallFov), index);
        
        centerPhase = smallFov(x,y,z);
        centerPhase = centerPhase ./ abs(centerPhase);
    end
    
    function range = getRange(self, length)
        mid = length / 2;
        width2 = length / self.fovReductionFactor / 2;
        range = round(mid - width2):round(mid + width2);
    end
    
    %% old hammond phase matching
    function vrcCoil = hammond(self, compl)
        centerPhase = self.getCenterPhaseHammond(compl);
        corrected = compl;
        for iCha = 1:size(compl,4)
            corrected(:,:,:,iCha) = corrected(:,:,:,iCha) * conj(centerPhase(iCha));
        end
        vrcCoil = weightedCombination(corrected, abs(corrected));
    end
    
    function centerPhase = getCenterPhaseHammond(self, compl)
        xRange = self.getRange(size(compl, 1));
        yRange = self.getRange(size(compl, 2));
        zRange = self.getRange(size(compl, 3));
        smallFov = compl(xRange, yRange, zRange, :);
        
        magProduct = prod(double(abs(smallFov)), 4);
        
        [~,index] = max(magProduct(:));
        [x, y, z] = ind2sub(size(smallFov), index);
        
        centerPhase = smallFov(x,y,z,:);
        centerPhase = centerPhase ./ abs(centerPhase);
    end
end
    
end

