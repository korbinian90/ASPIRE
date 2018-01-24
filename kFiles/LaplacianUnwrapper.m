classdef LaplacianUnwrapper < handle
    %LAPLACIANUNWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        yLim
        xLim
        matrixSize
    end
    
    methods
        function unwrapped = unwrapSlice(self, phase, mask)
            phase = self.cutFOV(phase, mask);
            laplacian = self.getLaplacian(phase);
            X = repmat((1 - ceil(size(phase, 2) / 2)):floor(size(phase, 2) / 2), [size(phase, 1) 1]);
            Y = repmat(((1 - ceil(size(phase, 1) / 2)):floor(size(phase, 1) / 2))', [1 size(phase, 2)]);
            K_sq = X .^ 2 + Y .^ 2;
            
            N = size(phase);        
            dkx = 1/N(2); 
            dky = 1/N(1); 
            lap_x = 2 - 2*cos((0:(N(2)-1))*dkx*2*pi);
            lap_y = 2 - 2*cos((0:(N(1)-1))*dky*2*pi);

            [lap_x,lap_y] = meshgrid(lap_x,lap_y);
            del_op = (lap_x + lap_y)/5;
            del_inv = 1./del_op;
            del_inv(1,1) = 0;    
            
            phase_k = fft2(laplacian) .* del_inv;
            phase_k(~isfinite(phase_k)) = 0;
            unwrapped = abs(ifft2(phase_k));
            unwrapped = self.regainFOV(unwrapped);
            unwrapped(~mask) = 0;
        end
        
        function laplacian = getLaplacian(~, phase)
            kernel = [0 1 0; 1 -4 1; 0 1 0];
            laplacian = imfilter(phase, kernel);
            laplacian = mod(laplacian + pi, 2 * pi) - pi;
        end
        
        function output = cutFOV(self, input, mask)
            self.matrixSize = size(input);
            self.yLim = minmax(find(sum(mask, 1)));
            self.xLim = minmax(find(sum(mask, 2))');
            output = input(self.xLim(1):self.xLim(2),self.yLim(1):self.yLim(2));
        end
        
        function output = regainFOV(self, input)
            leftPad = zeros(self.xLim(1) - 1, size(input, 2));
            rightPad = zeros(self.matrixSize(1) - self.xLim(2), size(input, 2));
            upperPad = zeros(self.matrixSize(1), self.yLim(1) - 1);
            lowerPad = zeros(self.matrixSize(1), self.matrixSize(2) - self.yLim(2));
            output = [upperPad [leftPad; input; rightPad] lowerPad];            
        end
    end
    
end

