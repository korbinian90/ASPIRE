classdef  BoxSegmenter < handle
    
    properties
    end
    
    methods (Static)
        function image = segment(image, mask)
            N = [size(image, 1) size(image, 2) size(image, 3)];
            boxSize = round(N / 10);
            
            for iLeft = 1:boxSize(1):N(1)
                iRange = iLeft:(min(iLeft + boxSize(1) - 1, N(1)));
                for jLeft = 1:boxSize(2):N(2)
                    jRange = (jLeft:min(jLeft + boxSize(2) - 1, N(2)));
                    for kLeft = 1:boxSize(3):N(3)
                        kRange = (kLeft:min(kLeft + boxSize(3) - 1, N(3)));
                        
                        image(iRange, jRange, kRange) = BoxSegmenter.threshold(image(iRange, jRange, kRange), mask(iRange, jRange, kRange));
                        
                        
                    end
                end
            end
        end
        
        function image = threshold(image, mask)
            masked = image(mask ~= 1);
            m = mean(masked);
            m = mean(masked(masked > m));
            
            image(image < 0.9 * m) = NaN;
        end
    end
    
end
