classdef Extrapolation < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, ~)
   
            smoothed = input;
            mag = sum(weight, 5);
            for iSlice = 1:size(input, 3)
%                 
%                 if self.weightedSmoothing
%                     w = weight(:,:,iSlice);
%                 else
%                     w = ones(size(input, 1), size(input,2));
%                 end
                w = mag(:,:,iSlice);
                tic
                re = self.getPolynomialFit(real(input(:,:,iSlice)), w);
                im = self.getPolynomialFit(imag(input(:,:,iSlice)), w);
                smoothed(:,:,iSlice) = complex(re, im);
                toc
            end
               
        end
        
        function fittedData = getPolynomialFit(~, slice, weight)
            [X, Y] = meshgrid(1:size(slice, 2), 1:size(slice, 1));
            mask = weight(:) > 0.1 * max(weight(:));
            F = scatteredInterpolant(X(mask), Y(mask), slice(mask));
            fittedData = F(X, Y);
        end

    end
    
end