classdef RootSumOfSquares
    %COMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function combined = combine(image, ~)
            if size(image, 5) == 1
                combined = image;
                return;
            end

            dimension = size(image);
            combined = zeros(dimension(1:4));

            for iCha = 1:dimension(5)
                combined = combined + abs(image(:,:,:,:,iCha)) .^ 2;
            end
            combined = combined ./ sqrt(abs(combined));
            
            combined(~isfinite(combined)) = 0;
        end
    end
    
end

