classdef AspireBipolarPoCalculator < AspirePoCalculator
    %ASPIREBIPOLARPOCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        po2
    end
    
    methods
        function calculatePo(self, compl)
            a12 = calculateAspirePo(compl, [1 2]);
            a23 = calculateAspirePo(compl, [2 3]);

            % only for 1st and 3rd echo
            self.po = (2 * a12) - a23;
            self.po2 = (2 * self.po - a12);
        end
        
        function compl = removePo(self, compl)
            nEchoes = size(compl,4);
            for iEco = 1:nEchoes
                % TODO store po normalized
                if mod(iEco, 2) == 1
                    compl(:,:,:,iEco,:) = squeeze(compl(:,:,:,iEco,:)) .* squeeze(conj(self.po)) ./ squeeze(abs(self.po));
                else
                    compl(:,:,:,iEco,:) = squeeze(compl(:,:,:,iEco,:)) .* squeeze(conj(self.po2)) ./ squeeze(abs(self.po2));
                end
            end
        end
    end
    
end

