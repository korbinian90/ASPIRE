classdef AspireBipolarPoCalculator < AspirePoCalculator
%% USES ECHOES 1, 2, 4

properties
    po2
end

methods
    % override
    function calculatePo(self, compl)
        diff12 = calculateHip(compl);
        diff23 = calculateHip(compl, [2 3]);
        
        readoutGradient2 = self.getReadoutGradientDivBy(diff12 .* conj(diff23), 2, size(compl, 5));
        
        self.po = self.calculateAspirePo(compl) .* readoutGradient2;
        self.po2 = self.po .* readoutGradient2;
        self.storage.write(self.po, 'po');
        self.storage.write(self.po2, 'po2');
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
        self.storage.write(self.po, 'poSmooth');
        self.storage.write(self.po2, 'po2Smooth');
    end
    
    
    function readoutGradient = getReadoutGradientDivBy(self, gradient4, div, nChannels)
        self.storage.write(gradient4, 'gradient4');

        sizeArr = size(gradient4);
        
        diffMap = gradient4(2:end,:,:,:) .* conj(gradient4(1:(end-1),:,:,:));
        self.storage.write(diffMap, 'diffMap');

        diff = sum(diffMap(:));
        gradient = angle(diff) / div;
        

        readoutDim = 1;
        rMin = -sizeArr(readoutDim)/2;
        rValues = rMin:(rMin + sizeArr(readoutDim) - 1);
        
        repSizes = sizeArr; repSizes(readoutDim) = 1;
        
        readoutGradient = repmat(rValues, repSizes) * gradient;
        readoutGradient = reshape(readoutGradient, sizeArr);
        readoutGradient = exp(1i * readoutGradient);
        self.storage.write(readoutGradient, 'readoutGradient');
        
        readoutGradient = repmat(readoutGradient, [1 1 1 nChannels]);
    end
end
    
end
