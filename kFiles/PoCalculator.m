classdef (Abstract) PoCalculator < handle
    
    properties (Abstract)
        po
    end
    
    methods (Abstract)
        calculatePo(self, compl)
    end
    
    methods
        function obj = PoCalculator()
        end
        
        function compl = removePo(self, compl)
            nEchoes = size(compl,4);
            for eco = 1:nEchoes
                % TODO store po normalized
                compl(:,:,:,eco,:) = squeeze(compl(:,:,:,eco,:)) .* squeeze(conj(self.po)) ./ squeeze(abs(self.po));
            end
        end
        
        % TODO refactor
        function smoothPo(self, sigmaInVoxel)
            nChannels = size(self.po,4);
            for iCha = 1:nChannels
                self.po(:,:,:,iCha) = weightedGaussianSmooth(self.po(:,:,:,iCha), sigmaInVoxel);
            end
        end
    end
    
    
end

