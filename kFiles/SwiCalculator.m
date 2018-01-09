classdef SwiCalculator < handle
    %SWICALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        storage
        smoother
        sigmaInMM
        power
        echoTimes
    end
    
    methods
        function obj = SwiCalculator(sigmaInMM, power)
            obj.sigmaInMM = sigmaInMM;
            obj.power = power;
        end
        
        function setup(self, data)
            self.storage = Storage(data);
            self.storage.setSubdir('swi');
            self.smoother = data.smoother;
            self.smoother.setup(mmToVoxel(self.sigmaInMM, data.nii_pixdim), 0, 0);
            self.echoTimes = data.TEs;
        end
        
        function setSlice(self, slice)
            self.storage.setSlice(slice);
        end
        
        function swi = calculate(self, compl)
            hp = self.highPassFilter(compl);
            combined = self.combineEchoes(hp);
            swi = self.calculateSwi(combined);
            self.storage.write(hp, 'hp');
            self.storage.write(combined, 'combined');
        end
        
        function hp = highPassFilter(self, compl)
            lowPassFiltered = self.smoother.smooth(compl);
            lowPassFiltered = exp(1i * angle(lowPassFiltered)); % only phase
            hp = compl .* conj(lowPassFiltered); % remove low frequency phase
        end
        
        function combined = combineEchoes(self, echoes)
            TEs = self.echoTimes;
            dim = size(echoes);
            repDim = [dim(1:3) 1];
            reshapeDim = [1 1 1 length(TEs)];
            echoes = echoes ./ repmat(reshape(TEs, reshapeDim), repDim);
            T2star = 30; % approx value for 7T
            weight = TEs .* exp(-TEs / T2star) / sum(TEs .* exp(-TEs / T2star));
            combined = sum(repmat(reshape(weight, reshapeDim), repDim) .* echoes, 4);
        end
        
        function swi = calculateSwi(self, compl)
            phase = angle(compl);
            phase(phase >= 0) = 1;
            phase(phase < 0) = ((phase(phase < 0) + pi) / pi) .^ self.power;
            swi = abs(compl) .* phase;
        end
    end
    
end

