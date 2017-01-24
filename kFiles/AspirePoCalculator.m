classdef AspirePoCalculator < PoCalculator
    
properties
    aspireEchoes
end

methods
    % override
    function setup(self, data)
        setup@PoCalculator(self, data); % call super-method
        self.aspireEchoes = [1 2];
        if isfield(data, 'aspire_echoes')
            self.aspireEchoes = data.aspire_echoes;
        end
    end
    % override
    function calculatePo(self, compl)
        self.po = self.calculateAspirePo(compl, self.aspireEchoes);
    end
end

methods (Static)
    function po = calculateAspirePo(compl, aspireEchoes)
        hip = calculateHip(compl, aspireEchoes);

        po = AspirePoCalculator.subtractHipFromEcho(compl, hip, aspireEchoes(1));
    end
end
    
end

