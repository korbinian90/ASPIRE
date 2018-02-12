classdef SimonMagNormalization < Combination
    %MAGSENSCALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        smoother
    end
    
    methods
        % override
        function setup(self, data)
            setup@Combination(self, data);
            
            self.smoother = data.combination_smoother;
            self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
        end
        
        function combined = combine(self, compl, ~)
            rsos = sqrt(sum(abs(compl) .^ 2, 5));
            simplSum = sum(abs(compl), 5);
            
            normalizeFactor = simplSum ./ rsos;
            self.storage.write(normalizeFactor, 'normalizeFactorBeforeSmooth');
            normalizeFactor = self.smoother.smooth(normalizeFactor);
            
            combined = rsos .* normalizeFactor;
            
            self.storage.write(rsos, 'rsos');
            self.storage.write(simplSum, 'simpleSum');
            self.storage.write(normalizeFactor, 'normalizeFactor');
        end
    end
    
end

