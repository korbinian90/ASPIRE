classdef AspireMagSensCalculator < AspirePoCalculator
    %ASPIRESENSCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       % override
       function setSens(~, ~)
       end
        
    end

    methods (Static)
        % override
        function po = calculateAspirePo(compl, aspireEchoes, m, storage)
            if nargin == 1
                aspireEchoes = [1 2];
            end
            
            echoDiff = AspireMagSensCalculator.calculateCombinedDifference(compl(:,:,:,aspireEchoes,:));
            
            if nargin == 3
                echoDiff = echoDiff .^ m;
            end
            
            dim = size(compl);
            po = zeros([dim(1:3) 1 size(compl, 5)]);
            for iCha = 1:size(po, 5)
                po(:,:,:,1,iCha) = abs(compl(:,:,:,aspireEchoes(1),iCha)) .* echoDiff;
            end
            
        end
        
        function echoDiff = calculateCombinedDifference(compl)
            dim = size(compl);
            echoDiff = zeros(dim(1:3));
            weightSum = zeros(dim(1:3));
            for iCha = 1:size(compl, 5)
                mag = abs(compl(:,:,:,1,iCha));
                mag2 = abs(compl(:,:,:,2,iCha));
                weightSum = weightSum + mag;
                echoDiff = echoDiff + mag .* mag ./ mag2;
            end
            echoDiff = echoDiff ./ weightSum;
            echoDiff(~isfinite(echoDiff)) = 0;
        end
        
    end
    
end

