classdef NoPoCalculator < PoCalculator
    %NOPOCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function po = calculatePo(self, compl)
            po = ones(size(compl));
        end
        
        % override
        function compl = removePo(self, compl)
        end
        
        % override
        function smoothPo(self, weight)
        end
    end
end

