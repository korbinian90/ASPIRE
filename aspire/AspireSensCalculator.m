classdef AspireSensCalculator < AspirePoCalculator
    %ASPIRESENSCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end

    methods (Static)
        % override
        function po = calculateAspirePo(compl, aspireEchoes, m)
            if nargin == 2
                m = 1;
            end
            po = calculateAspirePo@AspirePoCalculator(compl, aspireEchoes, m);
            po = PoCalculator.removeMag(po);
            mag = AspireSensCalculator.getMagAtTimeZero(compl(:,:,:,aspireEchoes,:), m);
            po = mag .* po;
        end
        
        function mag = getMagAtTimeZero(compl, m)
            dim = size(compl);
            mag = reshape(abs(compl(:,:,:,1,:)) .* (abs(compl(:,:,:,1,:)) ./ abs(compl(:,:,:,2,:))) .^ m, dim([1:3, 5]));
            mag(~isfinite(mag)) = 0.1;
        end
        
%         function po = calculateAspirePo(compl, aspireEchoes, m)
%             if nargin == 1
%                 aspireEchoes = [1 2];
%             end
%             
%             hip = calculateHip(compl, aspireEchoes);
%             mag = sum(abs(compl(:,:,:,aspireEchoes(1),:)) ./ abs(compl(:,:,:,aspireEchoes(2),:)), 5);
%             mag(~isfinite(mag)) = 0.1;
%             hip = mag .* exp(1i * angle(hip));
%             
%             if nargin == 3
%                 hip = hip .^ m;
%             end
% 
%             po = AspirePoCalculator.subtractFromEcho(compl, hip, aspireEchoes(1));
%         end
        
    end
    
end

