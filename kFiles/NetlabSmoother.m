classdef NetlabSmoother < Smoother
    %GAUSSIANBOXSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % implement
        function smoothed = smoothImplementation(self, input, weight, factor)
            sigma = self.sigmaInVoxel * factor;

            threshold = 0.25;
%                 weight = sum(weight, 5);
            % TODO slicewise for 3d
            mean_mask = weight >= mean(weight(:));
            mean_mask = weight >= mean(weight(mean_mask));
            mean_mask = weight >= mean(weight(mean_mask));
            mask = weight < threshold * mean(weight(mean_mask));
            self.storage.write(single(mask), 'mask');
            
            smoothed = zeros(size(input));
            for iCha = 1:size(input, 5)
                smoothed(:,:,:,1,iCha) = self.netlabSmoothing(input(:,:,:,1,iCha), mask);
            end
        end
        
        % override
        function smoothed = smooth(self, smoothed, weight, varargin)
            factor = 1;
            if nargin == 2
                weight = ones(size(smoothed));
            end
            if nargin == 4
                factor = varargin{1};
            end
            
            smoothed = self.smoothImplementation(smoothed, weight, factor);
        end
        
        function smoothed = netlabSmoothing(self, input, mask)
            addpath('/bilbo/home/keckstein/matlab/korbinian/experimental/netlab3_3');
            netReal = self.learn(real(input), mask);
            smoothedReal = self.evaluate(netReal, [size(input, 1) size(input, 2) size(input, 3)]);
            netImag = self.learn(imag(input), mask);
            smoothedImag = self.evaluate(netImag, [size(input, 1) size(input, 2) size(input, 3)]);
            smoothed = complex(smoothedReal, smoothedImag);
        end
        
        function net = learn(self, input, mask)
            nIn = 3;
            nHn = 150;
            nOn = 1;
            ofunc = 'linear';
            maxItr = 1;
            
            net = mlp(nIn, nHn, nOn, ofunc); 
            options = foptions();
            options(14) = maxItr;
            
            [in, out] = self.getTrainingData(input, mask);
            in = in / 256;
            out = out / 1000;
            
            order = randperm(length(in));
            
            net = netopt(net, options, in(order, :), out(order), 'scg');
        end
        
        function [in, out] = getTrainingData(self, input, mask)
            [X, Y, Z] = meshgrid(1:size(input, 1), 1:size(input, 2), 1:size(input, 3));
            in = [X(mask(:)) Y(mask(:)) Z(mask(:))];
            out = input(mask(:));
        end
        
        function smoothed = evaluate(self, net, dimension)
            [X, Y, Z] = meshgrid(1:dimension(1), 1:dimension(2), 1:dimension(3));
            grid = [X(:) Y(:) Z(:)] / 256;
            smoothed = mlpfwd(net, grid);
            smoothed = reshape(smoothed, dimension) * 1000;
        end
    end
    
end
