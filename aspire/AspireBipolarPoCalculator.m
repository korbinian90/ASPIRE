classdef AspireBipolarPoCalculator < AspirePoCalculator
%% USES ECHOES 1, 2, 4

properties
    po2
end

methods
    % override
    function calculatePo(self, compl)
        a12 = self.calculateAspirePo(compl, [1 2]);
        a24 = self.calculateAspirePo(compl, [2 4]);
        self.storage.write(a12, 'a12');
        self.storage.write(a24, 'a24');
        a12 = self.normalize(a12);
        a24 = self.normalize(a24);
        
        readoutGradient2 = self.getReadoutGradient2(a24 .* conj(a12));
        
        self.po = a12 .* readoutGradient2; % this is good
%         self.po = a24 .* conj(readoutGradient2); % this makes ripples
        self.po2 = a24;
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
    
    % TODO: perform smooth and normalize inside?
    
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

    
    function readoutGradient = getReadoutGradient2(self, gradient4)
        self.storage.write(gradient4, 'gradient4');

        sizeArr = size(gradient4);
        
        diffMap = gradient4(2:end,:,:,:) .* conj(gradient4(1:(end-1),:,:,:));
        self.storage.write(diffMap, 'diffMap');

        diff = sum(diffMap(:));
        gradient = angle(diff) / 2;
        

        readoutDim = 1;
        rMin = -sizeArr(readoutDim)/2;
        rValues = rMin:(rMin + sizeArr(readoutDim) - 1);
        
        repSizes = sizeArr; repSizes(readoutDim) = 1;
        
        readoutGradient = repmat(rValues, repSizes) * gradient;
        readoutGradient = reshape(readoutGradient, sizeArr);
        readoutGradient = exp(1i * readoutGradient);
        self.storage.write(readoutGradient, 'readoutGradient');
    end
end
    
end
