classdef MagSensCombination < SensitivityCombination
    %SENSITIVITYCOMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        % override
        function combined = combine(image, sens)
            combined = combine@SensitivityCombination(abs(image), sens);
        end
    end
    
end

