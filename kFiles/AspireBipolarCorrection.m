classdef AspireBipolarCorrection < handle

properties
    doNonLinearCorrection
    readoutDimension
    storage
    smoother
end

methods
    function obj = AspireBipolarCorrection(varargin)
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
    
    function setup(self, data)
        self.storage = Storage(data);
        self.storage.setSubdir('poCalculation');
        self.smoother = data.smoother;
        self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
    end
    
    function corrected = apply(self, compl)
        bipolarOffset2 = self.getOffsetCorrection(compl);
        
        bipolarOffset2 = self.smoother.smooth(bipolarOffset2);
        
        corrected = self.correct(compl, bipolarOffset2);
    end
    
    function compl = correct(~, compl, bipolarOffset2)
        for iEcho = 1:size(compl, 4)
            compl(:,:,:,iEcho) = compl(:,:,:,iEcho) .* conj(bipolarOffset2);
        end
        for iEcho = 2:2:size(compl, 4)
            compl(:,:,:,iEcho) = compl(:,:,:,iEcho) .* conj(bipolarOffset2);
        end
    end
    
    function bipolarOffset2 = getOffsetCorrection(self, compl)
        % linear correction
        diff21 = PoCalculator.normalize(compl(:,:,:,2) .* conj(compl(:,:,:,1)));
        diff32 = PoCalculator.normalize(compl(:,:,:,3) .* conj(compl(:,:,:,2)));
        gradient4 = PoCalculator.normalize(diff21 .* conj(diff32));
        
        bipolarOffset2 = self.getGradient(gradient4, 2);
        
        % constant correction
        offsetAngle2 = self.getConstantOffset(bipolarOffset2, gradient4);
        bipolarOffset2 = bipolarOffset2 * exp(1i * offsetAngle2);
        
        % non-linear correction
        if self.doNonLinearCorrection
            bipolarOffset2 = self.nonLinearCorrection(bipolarOffset2, gradient4);
        end
    end

    function readoutGradient = getGradient(self, gradient4, div)
        readoutDim = self.readoutDimension;
        self.storage.write(gradient4, 'gradient4');

        sizeArr = size(gradient4);
        shift = 10;
        if readoutDim == 1
            diffMap4 = PoCalculator.normalize(gradient4((1+shift):end,:,:,:) .* conj(gradient4(1:(end-shift),:,:,:)));
        elseif readoutDim == 2
            diffMap4 = PoCalculator.normalize(gradient4(:,(1+shift):end,:,:) .* conj(gradient4(:,1:(end-shift),:,:)));
        end
        self.storage.write(diffMap4, 'diffMap');

        diff = sum(diffMap4(:));
        gradient = angle(diff) / div / shift;

        rMin = -sizeArr(readoutDim)/2;
        rValues = rMin:(rMin + sizeArr(readoutDim) - 1);
        
        repSizes = sizeArr; repSizes(readoutDim) = 1;
        
        readoutGradient = repmat(rValues, repSizes) * gradient;
        readoutGradient = reshape(readoutGradient, sizeArr);
        readoutGradient = exp(1i * readoutGradient);
        self.storage.write(readoutGradient, 'readoutGradient');
    end
    
    function offset2 = getConstantOffset(~, readoutGradient2, gradient4)
        diff4 = gradient4 .* conj(readoutGradient2) .* conj(readoutGradient2);
        offset2 = angle(sum(diff4(:))) / 2;
    end
    
    function readoutGradient2 = nonLinearCorrection(self, readoutGradient2, gradient4)
        residual4 = gradient4 .* conj(readoutGradient2) .* conj(readoutGradient2);
        self.storage.write(residual4, 'residual');
        
        % TODO: is greater smoothing than for other PO required?
%         residual = self.smoother.smooth(residual, ones(size(residual)), 1.5);
%         self.storage.write(residual, 'smooth_residual');
        
        residual2 = angle(residual4) / 2;
        readoutGradient2 = angle(readoutGradient2);
        readoutGradient2 = exp(1i * (readoutGradient2 + residual2));
        self.storage.write(readoutGradient2, 'corrected_readoutGradient');
    end
end
    
end
