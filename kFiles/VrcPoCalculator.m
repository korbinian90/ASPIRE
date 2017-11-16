classdef VrcPoCalculator < PoCalculator
    
properties (Constant)
    fovReductionFactor = 5
end

methods
    % override
    function calculatePo(self, compl)
        vrcCoil = self.getVrcCoil(squeeze(compl(:,:,:,1,:)));
        self.po = self.subtractFromEcho(compl, vrcCoil, 1);
    end
   
end

methods (Access = private)
    

    function vrcCoil = getVrcCoil(self, compl)
        centered = self.phaseMatchingOfChannels(compl);
        vrcCoil = weightedCombination(centered, abs(centered));
    end
    
    
    function centered = phaseMatchingOfChannels(self, compl)
        centerPhases = self.getCenterPhase(compl);
        centered = compl;
        for iCha = 1:size(compl,4)
            centered(:,:,:,iCha) = compl(:,:,:,iCha) * conj(centerPhases(iCha));
        end
    end
    
    
    function centerPhase = getCenterPhase(self, compl)
        xRange = self.getRange(size(compl, 1));
        yRange = self.getRange(size(compl, 2));
        zRange = self.getRange(size(compl, 3));
        smallFov = compl(xRange, yRange, zRange, :);
        
        centerPhase = self.getCenterPhaseHammond(smallFov);
%         centerPhase = self.getCenterPhaseSeparate(smallFov);
%         centerPhase = self.getCenterManual(compl);
        
        centerPhase = centerPhase ./ abs(centerPhase);
    end
    
    
    function centerPhase = getPhaseOfMax(~, compl)
        mag = abs(compl);
        [~,index] = max(mag(:));
        centerPhase = compl(index);
    end
    
    
    function range = getRange(self, length)
        mid = length / 2;
        width2 = length / self.fovReductionFactor / 2;
        range = round(mid - width2):round(mid + width2);
    end
    
    
    %% old hammond phase matching
    function centerPhase = getCenterPhaseHammond(~, smallFov)
        magSum = sum(double(abs(smallFov)), 4);
        [~,index] = max(magSum(:));
        [x, y, z] = ind2sub(size(smallFov), index);
        centerPhase = smallFov(x,y,z,:);
    end
    
    %% not working sep phase matching    
    function centerPhase = getCenterPhaseSeparate(self, smallFov)
        nCha = size(smallFov, 4);
        centerPhase = zeros(1, nCha);
        for iCha = 1:nCha
            centerPhase(iCha) = self.getPhaseOfMax(smallFov(:,:,:,iCha));
        end
    end
    
    %% manual
    function centerPhase = getCenterManual(~, compl)
        COI = [195 220 48]
        centerPhase = compl(COI(1), COI(2), COI(3), :);
    end
    
end
    
end

