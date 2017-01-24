classdef AspireBipolarPoCalculator < AspirePoCalculator
    
properties
    po2
end

methods
    % override
    function calculatePo(self, compl)
        a12 = self.calculateAspirePo(compl, [1 2]);
        a23 = self.calculateAspirePo(compl, [2 3]);

        self.po = (2 * a12) - a23;
        self.po2 = (2 * self.po - a12);
    end
    % override
    function compl = removePo(self, compl)
        nEchoes = size(compl,4);
        for iEco = 1:nEchoes
            if mod(iEco, 2) == 1
                compl(:,:,:,iEco,:) = squeeze(compl(:,:,:,iEco,:)) .* squeeze(conj(self.po));
            else
                compl(:,:,:,iEco,:) = squeeze(compl(:,:,:,iEco,:)) .* squeeze(conj(self.po2));
            end
        end
    end
    % override
    function smoothPo(self, sigmaInVoxel)
        self.po = self.smooth(self.po, sigmaInVoxel);
        self.po2 = self.smooth(self.po2, sigmaInVoxel);
    end
    % override
    function normalizePo(self)
        self.po = self.normalize(self.po);
        self.po2 = self.normalize(self.po2);
    end
end
    
end

