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
    function po = calculateAspirePo(compl, aspireEchoes, m)
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
