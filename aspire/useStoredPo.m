classdef useStoredPo
    %USESTOREDPO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        path
    end
    
    methods
        function obj = AspireBipolarPoCalculator(path)
             obj.path = path;
        end
        
        function calculatePo(self, ~)
            nii = load_nii(self.path);
            self.po = nii.img;
        end
        
        % override
        function smoothPo(~, ~)
        end
    end
    
end

