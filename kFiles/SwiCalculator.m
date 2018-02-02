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
            self.smoother = data.swiSmoother;
            self.smoother.setup(mmToVoxel(self.sigmaInMM, data.nii_pixdim), 0, 0, self.storage);
            self.echoTimes = data.TEs;
        end
        
        function setSlice(self, slice)
            self.storage.setSlice(slice);
        end
        
        function swi = calculate(self, compl)
            unwrapped = self.unwrap(compl);
            hp = self.highPassFilter(unwrapped, abs(compl));
%             hp = angle(self.highPassFilterCompl(exp(1i * unwrapped)), abs(compl));
            combinedPhase = self.combineEchoesPhase(hp);
            combinedMag = self.combineEchoes(abs(compl));
            swi = self.calculateSwi(combinedMag, combinedPhase);
            self.storage.write(unwrapped, 'unwrapped');
            self.storage.write(hp, 'hp');
            self.storage.write(abs(compl), 'complMag');
            self.storage.write(combinedMag, 'combinedMag');
            self.storage.write(combinedPhase, 'combinedPhase');
        end
        
        % deprecated
        function hp = highPassFilterCompl(self, compl, weight)
            lowPassFiltered = self.smoother.smooth(compl, weight);
            lowPassFiltered = exp(1i * angle(lowPassFiltered)); % only phase
            self.storage.write(lowPassFiltered, 'lowPassFiltered');
            hp = compl .* conj(lowPassFiltered); % remove low frequency phase
        end
        
        function hp = highPassFilter(self, unwrapped, weight)
            lowPassFiltered = self.smoother.smooth(unwrapped, weight);
            self.storage.write(lowPassFiltered, 'lowPassFiltered');
            hp = unwrapped - lowPassFiltered; % remove low frequency phase
        end
        
        function combined = combineEchoesPhase(self, echoes)
            TEs = self.echoTimes / 1000; % TE in [ms]
            dim = size(echoes);
            repDim = [dim(1:3) 1];
            reshapeDim = [1 1 1 length(TEs)];
            echoes = echoes ./ repmat(reshape(TEs, reshapeDim), repDim);
            combined = combineEchoes(self, echoes);
        end
        
        function combined = combineEchoes(self, echoes)
            TEs = self.echoTimes / 1000; % TE in [ms]
            dim = size(echoes);
            repDim = [dim(1:3) 1];
            reshapeDim = [1 1 1 length(TEs)];
            T2star = 30; % approx value for 7T
            weight = TEs .* exp(-TEs / T2star) / sum(TEs .* exp(-TEs / T2star));
            combined = sum(repmat(reshape(weight, reshapeDim), repDim) .* echoes, 4);
        end
        
        function swi = calculateSwi(self, mag, phase)
%             minmaxPhase = minmax(phase(:)');
            med = 10 * median(abs(phase(mag > 0.5)));
            min = -med;
            max = med;
            phase = (phase - min) * (2 * pi / (max - min)) - pi;
%             phase = -20 * phase;
            phase(phase >= 0) = 1;
            phase(phase < -pi) = -pi;
            phase(phase < 0) = ((phase(phase < 0) + pi) / pi);% .^ self.power;
            swi = mag .* phase;
            self.storage.write(phase, 'phaseMask');
        end
        
        % deprecated
        function swi = calculateSwiCompl(self, compl)
            phase = -angle(compl);
            phase(phase >= 0) = 1;
            phase(phase < 0) = ((phase(phase < 0) + pi) / pi) .^ self.power;
            swi = abs(compl) .* phase;
        end
        
        function unwrapped = unwrap(self, compl)
            addpath('/bilbo/home/keckstein/matlab/vSharp');
            unwrapper = LaplacianUnwrapper;
            mask = abs(compl) > 0.5;
            unwrapped = zeros(size(compl));
            for iEco = 1:size(compl, 4)
                for iSlice = 1:size(compl, 3)
                    unwrapped(:,:,iSlice,iEco) = unwrapper.unwrapSlice(angle(compl(:,:,iSlice,iEco)), mask(:,:,iSlice,1));%unwrapVya2D(angle(compl(:,:,iSlice,iEco)));%
                end
            end
        end
    end
    
end

