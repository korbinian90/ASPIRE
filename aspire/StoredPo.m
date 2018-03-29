classdef StoredPo < PoCalculator
    %STOREDPO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fn_po
        fn_sens
        fn_real
        fn_imag
    end
    
    methods
        function obj = StoredPo(fn_po, fn_sens, fn_real, fn_imag)
            obj.fn_po = fn_po;
            if nargin >= 2
                obj.fn_sens = fn_sens;
            end
            if nargin >= 3
                obj.fn_real = fn_real;
            end
            if nargin >= 4
                obj.fn_imag = fn_imag;
            end
        end
        
        function calculatePo(self, ~)
            singleEchoTemp = self.storage.singleEcho;
            self.storage.singleEcho = 1;
            
            if ~isempty(self.fn_po) || ~isempty(self.fn_sens)
                self.po = 1;
                if ~isempty(self.fn_po)
                    image = self.storage.getImage(self.fn_po);
                    self.po = exp(1i * image);
                end
                if isprop(self, 'fn_sens')
                    image = self.storage.getImage(self.fn_sens);
                    self.po = self.po .* image;
                end
            else
                self.po = complex(self.storage.getImage(self.fn_real), self.storage.getImage(self.fn_imag));
            end
            
            self.storage.singleEcho = singleEchoTemp;
        end
        
        % override
        function smoothPo(~, ~)
        end
        
        % overrid
        function setSens(~,~)
        end
    end
    
end

