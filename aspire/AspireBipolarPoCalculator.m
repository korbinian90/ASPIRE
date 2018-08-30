classdef AspireBipolarPoCalculator < AspirePoCalculator

properties
    po2
    doNonLinearCorrection
    readoutDimension
end

methods
    function obj = AspireBipolarPoCalculator(varargin)
        if nargin >= 1 && strcmp(varargin{1}, 'non-linear correction')
            obj.doNonLinearCorrection = 1;
        else
            obj.doNonLinearCorrection = 0;
        end
        if nargin >= 2
            obj.readoutDimension = varargin{2};
        else
            obj.readoutDimension = 1;
        end
    end
    
    % override
    function calculatePo(self, compl)
        diff12 = self.normalize(calculateHip(compl));
        diff23 = self.normalize(calculateHip(compl, [2 3]));
        
        readoutGradient2 = self.getReadoutGradientDivBy(self.normalize(diff12 .* conj(diff23)), 2, size(compl, 5));
        
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
    function smoothPo(self, weight)
        self.po = self.smoother.smooth(self.po, weight);
        self.po2 = self.smoother.smooth(self.po2, weight);
    end
    
    % override
    function removeMagPo(self)
        self.po = self.removeMag(self.po);
        self.po2 = self.removeMag(self.po2);
        self.storage.write(self.po, 'poSmooth');
        self.storage.write(self.po2, 'po2Smooth');
    end
    
    % override
    function addToPo(self, term)
        for iCha = 1:size(self.po, 4)
            self.po(:,:,:,iCha) = self.po(:,:,:,iCha) .* term;
            self.po2(:,:,:,iCha) = self.po2(:,:,:,iCha) .* term;
        end
    end

    function readoutGradient = getReadoutGradientDivBy(self, gradient4, div, nChannels)
        
        readoutGradient = self.getGradient(gradient4, div);
        
        offsetAngle = self.getConstantOffset(readoutGradient, gradient4);
        readoutGradient = readoutGradient * exp(1i * offsetAngle);
        
        if self.doNonLinearCorrection
            readoutGradient = self.nonLinearCorrection(readoutGradient, gradient4);
        end
        
        readoutGradient = repmat(readoutGradient, [1 1 1 1 nChannels]);
    end
    
    function readoutGradient = getGradient(self, gradient4, div)
        readoutDim = self.readoutDimension;
        self.storage.write(gradient4, 'gradient4');

        sizeArr = size(gradient4);
        shift = 10;
        if readoutDim == 1
            diffMap = self.normalize(gradient4((1+shift):end,:,:,:) .* conj(gradient4(1:(end-shift),:,:,:)));
        elseif readoutDim == 2
            diffMap = self.normalize(gradient4(:,(1+shift):end,:,:) .* conj(gradient4(:,1:(end-shift),:,:)));
        end
        self.storage.write(diffMap, 'diffMap');

        diff = sum(diffMap(:));
        gradient = angle(diff) / div / shift;

        rMin = -sizeArr(readoutDim)/2;
        rValues = rMin:(rMin + sizeArr(readoutDim) - 1);
        
        repSizes = sizeArr; repSizes(readoutDim) = 1;
        
        readoutGradient = repmat(rValues, repSizes) * gradient;
        readoutGradient = reshape(readoutGradient, sizeArr);
        readoutGradient = exp(1i * readoutGradient);
        self.storage.write(readoutGradient, 'readoutGradient');
    end
    
    function offset = getConstantOffset(~, readoutGradient, gradient4)
        diff = gradient4 .* conj(readoutGradient);
        offset = angle(sum(diff(:)));
    end
    
    function readoutGradient = nonLinearCorrection(self, readoutGradient, gradient4)
        residual = gradient4 .* conj(readoutGradient) .* conj(readoutGradient);
        self.storage.write(residual, 'residual');
        
        % greater smoothing than for other PO required, otherwise bad phase
        % combination
        residual = self.smoother.smooth(residual, ones(size(residual)), 3);
        self.storage.write(residual, 'smooth_residual');
        
        residual = angle(residual) / 2;
        readoutGradient = angle(readoutGradient);
        readoutGradient = exp(1i * (readoutGradient + residual));
        self.storage.write(readoutGradient, 'corrected_readoutGradient');
    end
end
    
end
