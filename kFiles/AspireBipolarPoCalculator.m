classdef AspireBipolarPoCalculator < AspirePoCalculator
    
properties
    po2
end

methods
    % override
    function calculatePo(self, compl)
        a12 = self.calculateAspirePo(compl, [1 2]);
        a23 = self.calculateAspirePo(compl, [2 3], 2);
        self.writer.write(a12, 'a12');
        self.writer.write(a23, 'a23');
        a12 = self.normalize(a12);
        a23 = self.normalize(a23);
        
        self.po = (a12 .^ 2) .* conj(a23);
        self.po2 = (self.po .^2) .* conj(a12);
        self.writer.write(self.po, 'po');
        self.writer.write(self.po2, 'po2');
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
    function smoothPo(self)
        self.po = self.smooth(self.po, self.sigmaInVoxel);
        self.po2 = self.smooth(self.po2, self.sigmaInVoxel);
    end
    % override
    function normalizePo(self)
        self.po = self.normalize(self.po);
        self.po2 = self.normalize(self.po2);
    end
end
    
end

