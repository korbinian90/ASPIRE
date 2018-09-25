classdef SensitivityCombination < Combination
    %SENSITIVITYCOMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function combined = combine(image, sens)
            if size(image, 5) == 1
                combined = image;
                return;
            end

            dimension = size(image);
            combined = zeros(dimension(1:(end-1)));
            sensWeight = zeros(dimension(1:3));

            for iChannel = 1:dimension(5)
                sensWeight = sensWeight + sens(:,:,:,1,iChannel) .^ 2;
%                 combined = combined + image(:,:,:,:,iChannel) .* repmat(sens(:,:,:,1,iChannel), [1 1 1 size(combined, 4)]);
                combined = combined + image(:,:,:,:,iChannel) .* sens(:,:,:,1,iChannel);
            end
            
            
            for iEco = 1:size(combined,4)
                combined(:,:,:,iEco) = combined(:,:,:,iEco) ./ sensWeight;
            end
            
%             mask = stableMask(sensWeight);
%             mask = stableMask(abs(combined(:,:,:,1)));
%             mask = repmat(mask, [1, 1, 1, size(combined, 4)]);
%             combined(~mask | ~isfinite(combined)) = 0;
            combined(~isfinite(combined)) = 0;
        end
    end
    
end

