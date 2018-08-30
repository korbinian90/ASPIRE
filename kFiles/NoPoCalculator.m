classdef NoPoCalculator < PoCalculator
    %NOPOCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function calculatePo(self, compl)
            self.po = ones(size(compl), 'single');
        end
        
        % override
        function compl = removePo(self, compl)
        end
        
        % override
        function smoothPo(self, weight)
        end
    end
end

