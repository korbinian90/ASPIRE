classdef PolyFitWeighted < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, ~)
   
            smoothed = input;
            for iSlice = 1:size(input, 3)
                if self.weightedSmoothing
                    smoothed(:,:,iSlice) = self.getPolynomialFit(input(:,:,iSlice), weight(:,:,iSlice));
                else
                    smoothed(:,:,iSlice) = self.getPolynomialFit(input(:,:,iSlice), ones(size(input, 1), size(input,2)));                   
                end
            end
               
        end
        
        function fittedData = getPolynomialFit(~, slice, weight)
            order = 5;
            x = 1:size(slice, 1);
            y = 1:size(slice, 2);
            P = polyfitweighted2(x, y, slice, order, weight);
            fittedData = polyval2(P, x, y);
        end

    end
    
end

