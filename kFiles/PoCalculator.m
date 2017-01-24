classdef (Abstract) PoCalculator < handle
   
properties
    po
    sigmaInVoxel
end

methods (Abstract)
    calculatePo(self, compl)
end

methods
    function setup(self, data)
        self.sigmaInVoxel = data.smoothingKernelSizeInVoxel;
    end
    
    function compl = removePo(self, compl)
        nEchoes = size(compl,4);
        for eco = 1:nEchoes
            compl(:,:,:,eco,:) = squeeze(compl(:,:,:,eco,:)) .* squeeze(conj(self.po));
        end
    end

    function smoothPo(self)
        self.po = self.smooth(self.po, self.sigmaInVoxel);
    end

    function normalizePo(self)
        self.po = self.normalize(self.po);
    end
end

methods (Static)
    function po = smooth(po, sigmaInVoxel)
        nChannels = size(po,4);
        for iCha = 1:nChannels
            po(:,:,:,iCha) = weightedGaussianSmooth(po(:,:,:,iCha), sigmaInVoxel);
        end
    end

    function po = normalize(po)
        po = po ./ abs(po);
    end
    
    function po = subtractHipFromEcho(compl, hip, echo)
        nChannels = size(compl, 5);
        size_compl = size(compl);

        po = complex(zeros([size_compl(1:3) nChannels], 'single'));
        for iCha = 1:nChannels
            po_double = double(compl(:,:,:,echo,iCha)) .* double(conj(hip));
            po(:,:,:,iCha) = single(po_double);
        end
    end
end

end

