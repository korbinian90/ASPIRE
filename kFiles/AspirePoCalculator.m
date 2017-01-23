classdef AspirePoCalculator < PoCalculator
    
    properties
        po
        aspireEchoes
    end
    
    methods
        function obj = AspirePoCalculator()
            obj.aspireEchoes = [1 2];
        end
        
        function calculatePo(self, compl)
            self.po = calculateAspirePo(compl, self.aspireEchoes);
        end
    end
    
end

