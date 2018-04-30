classdef  BoxSegmenter < handle
    
    properties
    end
    
    methods (Static)
        function wm_mask = segment(image, mask)
            N = [size(image, 1) size(image, 2) size(image, 3)];
            boxSize = round(N / 15);
            halfBoxSize = round(boxSize / 2);
            wm_mask = mask;
            
            for iLeft = 1:halfBoxSize(1):N(1)
                iRange = iLeft:(min(iLeft + boxSize(1) - 1, N(1)));
                for jLeft = 1:halfBoxSize(2):N(2)
                    jRange = (jLeft:min(jLeft + boxSize(2) - 1, N(2)));
                    for kLeft = 1:halfBoxSize(3):N(3)
                        kRange = (kLeft:min(kLeft + boxSize(3) - 1, N(3)));
                        
                        wm_mask(iRange, jRange, kRange) = wm_mask(iRange, jRange, kRange) & BoxSegmenter.threshold(image(iRange, jRange, kRange), mask(iRange, jRange, kRange));
                        
                        
                    end
                end
            end
        end
        
        function wm_mask = threshold(image, mask)
            masked = image(mask);
            m = mean(masked);
            m = mean(masked(masked > m & masked < 2 * m));
            % TODO could be improved by removing linear intensity variation
            
            wm_mask = mask;
            wm_mask(image < 0.9 * m) = 0;
            wm_mask(image > 1.5 * m) = 0;
        end
    end
    
end
