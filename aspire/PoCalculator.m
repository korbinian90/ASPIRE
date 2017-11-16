classdef (Abstract) PoCalculator < handle
   
properties
    po
    sigmaInVoxel
    storage
    smooth3d
end

methods (Abstract)
    calculatePo(self, compl)
end

methods
    function setup(self, data)
        self.sigmaInVoxel = data.smoothingKernelSizeInVoxel;
        self.smooth3d = data.smooth3d;
        self.storage = Storage(data);
        self.storage.setSubdir('poCalculation');
    end
    
    function preprocess(~)
    end
    
    function setSlice(self, slice)
        self.storage.setSlice(slice);
    end
    
    function compl = removePo(self, compl)
        nEchoes = size(compl,4);
        for eco = 1:nEchoes
            compl(:,:,:,eco,:) = squeeze(compl(:,:,:,eco,:)) .* squeeze(conj(self.po));
        end
    end

    function smoothPo(self, weight)
        self.po = self.smooth(self.po, self.sigmaInVoxel, weight);
    end

    function normalizePo(self)
        self.po = self.normalize(self.po);
    end

    function po = smooth(self, po, sigmaInVoxel, weight)
        nChannels = size(po,4);
        for iCha = 1:nChannels
            if self.smooth3d
                po(:,:,:,iCha) = weightedGaussianSmooth3D(po(:,:,:,iCha), sigmaInVoxel, weight);
            else
                po(:,:,:,iCha) = weightedGaussianSmooth(po(:,:,:,iCha), sigmaInVoxel, weight);
            end
        end
    end
end

methods (Static)
    
    function po = normalize(po)
        po = po ./ abs(po);
    end
    
    function po = subtractFromEcho(compl, hip, echo)
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

