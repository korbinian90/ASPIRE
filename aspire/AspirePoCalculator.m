classdef AspirePoCalculator < PoCalculator
    
properties
    aspireEchoes
    iterativeSteps
end

methods
    % override
    function setup(self, data)
        setup@PoCalculator(self, data); % call super-method
        self.aspireEchoes = [1 2];
        if isfield(data, 'aspire_echoes')
            self.aspireEchoes = data.aspire_echoes;
        end
        self.iterativeSteps = data.iterativeSteps;
    end
    % override
    function calculatePo(self, compl)
        self.po = self.calculateAspirePo(compl, self.aspireEchoes, 1, self.storage);
    end
    
    % override
    function iterativeCorrection(self, compl)
        if self.iterativeSteps
            compl = self.removePo(compl);
            combined = weightedCombinationAspire(compl, abs(self.po));
            phaseDiff = combined(:,:,:,2) .* conj(combined(:,:,:,1));
            residual = combined(:,:,:,1) .* (conj(phaseDiff) ./ abs(phaseDiff));
            residual(~isfinite(residual)) = 0;
            poTerm = ones(size(residual));

            self.storage.write(compl(:,:,:,:,1), 'compl');
            self.storage.write(abs(compl(:,:,:,:,1)), 'abscompl');
            self.storage.write(residual, 'residualNaN');
            self.storage.write(angle(combined), 'combined');
            self.storage.write(phaseDiff, 'phaseDiff');

            for iStep = 1:self.iterativeSteps
                residualSmooth = self.smoother.smooth(residual, abs(combined(:,:,:,1)));
                poTerm = poTerm .* residualSmooth ./ abs(residualSmooth);

                self.storage.write(residual, ['residual' num2str(iStep)]);
                self.storage.write(residualSmooth, ['residualSmooth' num2str(iStep)]);
                self.storage.write(poTerm, ['poTerm' num2str(iStep)]);

                residual = residual .* (conj(residualSmooth) ./ abs(residualSmooth));
            end
            self.addToPo(poTerm);
        end
    end
    
    function addToPo(self, term)
        for iCha = 1:size(self.po, 4)
            self.po(:,:,:,iCha) = self.po(:,:,:,iCha) .* term;
        end
    end
end

methods (Static)
    function po = calculateAspirePo(compl, aspireEchoes, m, storage)
        if nargin == 1
            aspireEchoes = [1 2];
        end
        
        hip = calculateHip(compl, aspireEchoes);
        
        if nargin == 3
            hip = hip .^ m;
        end

        po = AspirePoCalculator.subtractFromEcho(compl, hip, aspireEchoes(1));
    end
end
    
end
